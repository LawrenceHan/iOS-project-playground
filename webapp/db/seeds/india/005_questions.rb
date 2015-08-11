puts 'Creating questions '

# Hospital
['Convenient location', 'Cleanliness', 'Appointment making service'].each do |content|
  Question.where(category: 'hospital', content: content).first_or_create(is_optional: false, question_type: 'rating')
  printf '.'
end

['Waiting time'].each do |content|
  options = [["No waiting", 0], ["5 minutes", 5], ["10 minutes", 10], ["15 minutes", 15],
             ["30 minutes", 30], ["45 minutes", 45], ["1 hour", 60], ["1 hour 15 minutes", 75],
             ["1 hour 30 minutes", 90], ["1 hours 45 minutes", 105], ["2 hours ", 120], ["2 hours 30 minutes", 150],
             ["3 hours", 180], ["3 hours 30 minutes", 210], ["longer", 240]]
  Question.where(category: 'hospital', content: content).first_or_create(
    is_optional: false, question_type: 'waiting_time', options: options)
  printf '.'
end

["Modern facilities", "Comfort level", "Range of medical services", "Attentiveness and politeness"].each do |content|
  Question.where(category: 'hospital', content: content).first_or_create(is_optional: true, question_type: 'rating')
  printf '.'
end


# Physician
["Explains clearly", "Listens patiently", "Thorough examination", "Accurate diagnosis", "Treatment success"].each do |content|
  Question.where(category: 'physician', content: content).first_or_create(is_optional: false, question_type: 'rating')
  printf '.'
end

["Friendly nature", "Includes you in treatment plan", "Follow-up availability"].each do |content|
  Question.where(category: 'physician', content: content).first_or_create(is_optional: true, question_type: 'rating')
  printf '.'
end

['Consultation duration'].each do |content|
  options = [["5 minutes", 5], ["10 minutes", 10], ["15 minutes", 15], ["20 minutes", 20],
             ["30 minutes", 30], ["45 minutes", 45], ["1 hour", 60], ["1 hour 15 minutes", 75],
             ["1 hours 30 minutes", 90], ["longer", 120]]
  Question.where(category: 'physician', content: content).first_or_create(
    is_optional: true, question_type: 'waiting_time', options: options)
  printf '.'
end

['Consultation price'].each do |content|
  Question.where(category: 'physician', content: content).first_or_create(is_optional: true, question_type: 'price')
  printf '.'
end


# Medication
["Effectiveness", "Ease of use", "Tolerance", "Price"].each do |content|
  Question.where(category: 'medication', content: content).first_or_create(is_optional: false, question_type: 'rating')
  printf '.'
end

puts ''
