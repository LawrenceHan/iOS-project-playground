DOSAGE = %w(一勺 三勺 10克 100克 200克 300克 50克 一滴 2滴 3滴)
INTAKE_FREQUENCY = %w(一天三次 一天五次 一天一次 一星期一次 一月一次 一星期三次)
STATUS = %w(pending rejected published)

puts 'Creating hospital reviews '
MedicalExperience.all.each do |m|
  answers_attributes = Question.with_category('hospital').map do |question|
    if question.question_type == 'waiting_time'
      { question_id: question.id, waiting_time: (5..300).to_a.sample }
    else
      { question_id: question.id, rating: (0..5).to_a.sample }
    end
  end
  HospitalReview.create(
    medical_experience_id: m.id,
    reviewable_id: m.hospital_id,
    note: Faker::LoremCN.paragraph,
    status: STATUS.sample,
    completion: [0.21, 0.34, 0.55, 0.27, 0.97, 0.62].sample,
    answers_attributes: answers_attributes
  )
  printf '.'
end

puts ''

puts 'Creating physician reviews '
if PhysicianReview.count < 200
  HospitalReview.all.each do |h|
    h.hospital.physicians.sample([2,4,1,7].sample).each do |p|
      # Rating
      answers_attributes = Question.with_category('physician').map{|question| { question_id: question.id, rating: (0..5).to_a.sample } }
      p.physician_reviews.create(
        medical_experience_id: h.medical_experience_id,
        note: Faker::LoremCN.paragraph,
        status: STATUS.sample,
        completion: [0.21, 0.34, 0.55, 0.47, 0.93, 0.62].sample,
        answers_attributes: answers_attributes
      )
      printf '.'
    end
  end
end


puts ''

puts 'Creating medication reviews '
(200 - MedicationReview.count).times do |i|
  # Rating
  answers_attributes = Question.with_category('medication').map{|question| { question_id: question.id, rating: (0..5).to_a.sample } }
  MedicationReview.create(
    medical_experience: MedicalExperience.order('RANDOM()').first,
    reviewable_id: Medication.order('RANDOM()').first.id,
    note: Faker::LoremCN.paragraph,
    status: STATUS.sample,
    dosage: DOSAGE.sample,
    intake_frequency: INTAKE_FREQUENCY.sample,
    duration: '12 days',
    adverse_effects: Faker::Lorem.word,
    completion: [0.21, 0.34, 0.15, 0.27, 0.87, 0.62].sample,
    answers_attributes: answers_attributes
  )
  printf '.'
end

puts ''
