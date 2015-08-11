# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :review do
    medical_experience
  end

  factory :hospital_review, parent: :review, class: 'HospitalReview' do
    hospital
  end

  factory :physician_review, parent: :review, class: 'PhysicianReview' do
    physician
  end

  factory :medication_review, parent: :review, class: 'MedicationReview' do
    medication
  end
end
