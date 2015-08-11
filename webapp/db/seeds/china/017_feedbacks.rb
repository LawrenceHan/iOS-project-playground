puts 'Creating feedbacks '

(100 - Feedback.count).times do |x|
  Feedback.create(
    user_id: User.order('RANDOM()').first.id,
    content: Faker::LoremCN.words(10).join,
    skip_notification: true
  )

  printf '.'
end

puts ''
