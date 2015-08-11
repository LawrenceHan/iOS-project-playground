require 'rails_helper'

# ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe Hospital do
  it "default is valid" do
   hospital = create :hospital
   expect(hospital).to be_valid
  end

  it "unique vendor_id" do
    create(:hospital, vendor_id: 'M1000')
    hospital = build(:hospital, vendor_id: 'M1000')
    hospital.valid?
    expect(hospital.errors[:vendor_id]).to be_include("has already been taken")
  end

  it "string latitude/longitude are converted" do
    hospital = build(:hospital, vendor_id: 'M1000', latitude: "31.2000", longitude: "121.5000")
    expect(hospital.latitude).to eq(31.2)
    expect(hospital.longitude).to eq(121.5)
  end

  it "nearby search" do
    hospital = create(:hospital, name: 'Shanghai hospital', latitude: "31.2123", longitude: "121.5123")
    create(:hospital, name: 'New Delhi hospital', latitude: "28.6139", longitude: "77.2089")
    expect(Hospital.nearby(31.2, 121.5, 100.to_f).map(&:id)).to eq([hospital.id])
  end

  it "converts average waiting time - minutes only" do
    expect(Hospital.human_avg_waiting_time("1")).to eq("1min")
  end

  it "converts average waiting time - hours" do
    expect(Hospital.human_avg_waiting_time("120")).to eq("2h ")
  end

  it "converts average waiting time - hours and minutes" do
    expect(Hospital.human_avg_waiting_time("121")).to eq("2h 1min")
  end

  it "converts average waiting time - hours and minutes (localized)" do
    I18n.locale = "zh-CN"
    expect(Hospital.human_avg_waiting_time("121")).to eq("2小时1分钟")
  end

  it "human departments when departments is empty" do
    hospital = create(:hospital, vendor_id: 'M1000')
    expect(hospital.human_departments).to eq ""
  end

  it "human departments when departments are presents" do
    dept1 = build(:department, name: "dept1")
    dept2 = build(:department, name: "dept2")
    hospital = create(:hospital, departments: [dept1, dept2])
    expect(hospital.human_departments).to eq("dept1,dept2")
  end

  it "#update_avg_waiting_time! should recalculate average waiting time" do
    hospital = create :hospital
    create :hospital_review, hospital: hospital
    hospital.update_avg_waiting_time!
    expect(hospital.avg_waiting_time).to eq(nil)
  end

  it "#update_avg_rating! should recalculate average rating (auto-published)" do
    hospital = create :hospital
    question = create :question, category: 'hospital', question_type: 'rating'
    answer1 = create :answer, rating: 1.0, question: question
    answer2 = create :answer, rating: 2.0, question: question
    answer3 = create :answer, rating: 3.0, question: question
    answer4 = create :answer, rating: 4.0, question: question

    create :hospital_review, answers: [answer4], status: 'published', hospital: hospital
    create :hospital_review, answers: [answer3], status: 'pending', hospital: hospital
    create :hospital_review, answers: [answer2], status: 'rejected', hospital: hospital

    expect(hospital.published_hospital_reviews.length).to eq(3),
      "there should be three hospital reviews"

    expect(hospital.avg_rating).to eq(3.0),
      "status is overriden to published, so the calculation is (2+3+4) / 3 = 3"

    expect(hospital.avg_rating).to eq(3.0),
      "review added, but recalculation not called yet"

    create :hospital_review, answers: [answer2], status: 'published', hospital: hospital

    expect(hospital.avg_rating).to eq(2.8),
      "after adding a new version, the calculation should be (4+3+2+2)/4 = 2.75 rounded up to 2.8"
  end

  it "#update_avg_rating! should recalculate average rating < 2.5" do
    hospital = create :hospital
    question = create :question, category: 'hospital', question_type: 'rating'

    answer1 = create :answer, rating: 1.0, question: question
    answer3 = create :answer, rating: 3.0, question: question

    review1 = create :hospital_review, answers: [answer1], hospital: hospital
    review2 = create :hospital_review, answers: [answer1], hospital: hospital
    review3 = create :hospital_review, answers: [answer3], hospital: hospital

    expect(hospital.published_hospital_reviews.length).to eq(1),
      "there should be one hospital published reviews, got #{hospital.published_hospital_reviews.length}"

    expect(hospital.avg_rating).to eq(3.0),
      "review rating at 1 and 2 which are below 2.5, so automatically at pending"

    review1.status = 'published'
    review1.save

    review2.status = 'published'
    review2.save

    hospital.reload

    expect(hospital.published_hospital_reviews.length).to eq(3),
      "there should be three hospital published reviews, got #{hospital.published_hospital_reviews.length}"

    expect(hospital.avg_rating).to eq(1.7),
      "after adding a new version, the calculation should be (1+1+3)=5, 5/3=1.7 got #{hospital.avg_rating}"
  end


  describe 'merging' do
    it 'should be able to merge two hospitals into one' do
      expect {
        @hospital_a = create :hospital, name: 'Hospital A'
        @hospital_b = create :hospital, name: 'Hospital B'
      }.to change { Hospital.count }.by(2)

      # We should have one less hospital
      expect {
        @hospital_b.merge_into!(@hospital_a)
      }.to change { Hospital.count }.by(-1)

      # .. and it should be Hospital A
      expect(Hospital.first.name).to eq('Hospital A')
    end

    it 'should move the departments to one hospital' do
      dept1_a = build :department, name: "A - Department 1"
      dept2_a = build :department, name: "A - Department 2"
      @hospital_a = create :hospital, name: 'Hospital A', departments: [dept1_a, dept2_a]

      dept1_b = build :department, name: "B - Department 1"
      dept2_b = build :department, name: "B - Department 2"
      @hospital_b = create :hospital, name: 'Hospital B', departments: [dept1_b, dept2_b]

      expect {
        @hospital_b.merge_into!(@hospital_a)
      }.not_to change { Department.count }

      # We should have four departments in hospital A:
      #  1. A - Department 1
      #  2. A - Department 2
      #  3. B - Department 1
      #  4. B - Department 2

      expect(@hospital_a.departments.count).to eq(4)
    end

    it "should not double include the same department twice" do
      dept1_a = build :department, name: "A - Department 1"
      dept2_a_b = build :department, name: "A & B - Department 2"
      @hospital_a = create :hospital, name: 'Hospital A', departments: [dept1_a, dept2_a_b]

      dept1_b = build :department, name: "B - Department 1"
      @hospital_b = create :hospital, name: 'Hospital B', departments: [dept1_b, dept2_a_b]

      # We should have one less department hospital assignment
      expect {
        @hospital_b.merge_into!(@hospital_a)
      }.to change { DepartmentsHospital.count }.by(-1)

      # .. and we should have three departments in hospital A:
      #  1. A - Department 1
      #  2. A & B - Department 2
      #  3. B - Department 1
      expect(@hospital_a.departments.count).to eq(3)
    end

    it "should merge the physicians to the merged hospital" do
      @hospital_a = create :hospital, name: 'Hospital A'
      @hospital_b = create :hospital, name: 'Hospital B'

      physician_a = create :physician, name: 'Physician A', hospital: @hospital_a
      physician_b = create :physician, name: 'Physician B', hospital: @hospital_b

      # Make sure the physicians are well assigned
      expect(@hospital_a.physicians).to include(physician_a)
      expect(@hospital_b.physicians).to include(physician_b)

      # Physicians should not be destroyed
      expect {
        @hospital_b.merge_into!(@hospital_a)
      }.not_to change { Physician.count }

      # .. and we should have the two physicians attached to Hospital A
      #  1. Physician A
      #  2. Physician B
      expect(@hospital_a.reload.physicians.count).to eq(2)
    end

    it "should merge the medical experiences" do
      @hospital_a = create :hospital, name: 'Hospital A'
      @hospital_b = create :hospital, name: 'Hospital B'

      user = create :user

      medical_experience_a = create :medical_experience, hospital: @hospital_a
      medical_experience_b = create :medical_experience, hospital: @hospital_b

      # Physicians should not be destroyed
      expect {
        @hospital_b.merge_into!(@hospital_a)
      }.not_to change { MedicalExperience.count }

      # .. and both should be assigned to Hospital A
      expect(@hospital_a.medical_experiences.count).to eq(2)
    end

    it "should merge the hospital reviews" do
      @hospital_a = create :hospital, name: 'Hospital A'
      @hospital_b = create :hospital, name: 'Hospital B'

      expect {
        hospital_review_1 = create :hospital_review, type: 'HospitalReview', hospital: @hospital_a
        hospital_review_2 = create :hospital_review, type: 'HospitalReview', hospital: @hospital_b
      }.to change { HospitalReview.count }.by(2)

      # Hospital Reviews should not be destroyed
      expect {
        @hospital_b.merge_into!(@hospital_a)
      }.not_to change { HospitalReview.count }

      # .. and both should be assigned to Hospital A
      expect(@hospital_a.hospital_reviews.count).to eq(2)
    end

    it "should also support the absorption of an hospital into another" do
      @hospital_a = create :hospital, name: 'Hospital A'
      @hospital_b = create :hospital, name: 'Hospital B'

      expect(@hospital_b).to receive(:merge_into!).with(@hospital_a)

      @hospital_a.absorb!(@hospital_b)
    end

    it "should re-assign children hospital to the merged hospital" do
      @hospital_a = create :hospital, name: 'Hospital A'
      @hospital_b = create :hospital, name: 'Hospital B'
      @hospital_b_a = create :hospital, name: 'Hospital B', parent_hospital: @hospital_b

      expect(@hospital_b.sub_hospitals).to eq([@hospital_b_a])

      # Sub-hospital should not be destroyed
      expect {
        @hospital_b.merge_into!(@hospital_a)
      }.to change { Hospital.count }.by(-1)

      # .. and hospital_b_a should be a sub hospital of hospital a
      expect(@hospital_a.sub_hospitals).to eq([@hospital_b_a])
    end

    it "should update avg waiting time on the merged hospital" do
      @hospital_a = create :hospital, name: 'Hospital A'
      @hospital_b = create :hospital, name: 'Hospital B'

      expect(@hospital_a).to receive(:update_avg_waiting_time!)

      @hospital_b.merge_into!(@hospital_a)
    end

    it "should update avg rating on the merged hospital" do
      @hospital_a = create :hospital, name: 'Hospital A'
      @hospital_b = create :hospital, name: 'Hospital B'

      expect(@hospital_a).to receive(:update_avg_rating!)

      @hospital_b.merge_into!(@hospital_a)
    end

    it "should prevent merging into itself" do
      @hospital_a = create :hospital, name: 'Hospital A'

      expect {
        @hospital_a.merge_into!(@hospital_a)
      }.to raise_error "Can't merge into itself"
    end

    it "should prevent to merge hospitals not persisted hospitals" do
      @hospital_a = build :hospital, name: 'Hospital A'
      @hospital_b = create :hospital, name: 'Hospital B'

      expect {
        @hospital_b.merge_into!(@hospital_a)
      }.to raise_error "Can't merge non-persisted hospital"

      @hospital_c = create :hospital, name: 'Hospital A'
      @hospital_d = build :hospital, name: 'Hospital B'

      expect {
        @hospital_c.merge_into!(@hospital_d)
      }.to raise_error "Can't merge non-persisted hospital"
    end
  end

  context "#highly_reviews_departments" do
    let!(:hospital) { create :hospital }
    let!(:department1) { create :department, name: 'Department 1' }
    let!(:department2) { create :department, name: 'Department 2' }
    let!(:department3) { create :department, name: 'Department 3' }
    let!(:department_hospital1) { create :departments_hospital, hospital: hospital, department: department1 }
    let!(:department_hospital2) { create :departments_hospital, hospital: hospital, department: department2 }
    let!(:department_hospital3) { create :departments_hospital, hospital: hospital, department: department3 }
    let!(:physician1) { create :physician, hospital: hospital, department: department1 }
    let!(:physician2) { create :physician, hospital: hospital, department: department2 }
    let!(:physician3) { create :physician, hospital: hospital, department: department1 }
    let!(:physician4) { create :physician, hospital: hospital, department: department3 }
    let!(:medical_experience1) { create :medical_experience }
    let!(:medical_experience2) { create :medical_experience }
    let!(:medical_experience3) { create :medical_experience }
    let!(:physician_review1) { create :physician_review, status: 'published', physician: physician1, medical_experience: medical_experience1 }
    let!(:physician_review2) { create :physician_review, status: 'published', physician: physician3, medical_experience: medical_experience2 }
    let!(:physician_review3) { create :physician_review, status: 'published', physician: physician1, medical_experience: medical_experience3 }
    let!(:physician_review4) { create :physician_review, status: 'published', physician: physician3, medical_experience: medical_experience1 }
    let!(:physician_review5) { create :physician_review, status: 'published', physician: physician2, medical_experience: medical_experience2 }
    let!(:physician_review6) { create :physician_review, status: 'published', physician: physician2, medical_experience: medical_experience1 }
    let!(:physician_review7) { create :physician_review, status: 'published', physician: physician4, medical_experience: medical_experience3 }

    it "gets departments sort by reviews count" do
      expect(hospital.highly_reviews_departments).to eq([
        {"id" => department1.id, "name" => department1.name, "reviews_count" => 4, "physicians_count" => 2},
        {"id" => department2.id, "name" => department2.name, "reviews_count" => 2, "physicians_count" => 1}
      ])
    end
  end
end
