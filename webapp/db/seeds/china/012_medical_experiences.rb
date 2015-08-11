puts 'Creating medical experiences '

(100 - MedicalExperience.count).times do |i|
  MedicalExperience.create(
    user: User.order('RANDOM()').first,
    hospital: Hospital.order('RANDOM()').first,
    symptom_ids: Symptom.pluck(:id).sample([0,1,2,3,4].sample),
    condition_ids: Condition.pluck(:id).sample([0,1,2,3,4].sample),
    network_visible: TRUE_OR_FALSE.sample,
    behalf: '妈妈'
  )
  printf '.'
end

puts ''
