puts 'Creating reports '

(100 - Report.count).times do |x|
  review =  Review.order('RANDOM()').first

  Report.where(
    user_id: User.order('RANDOM()').first.id,
    reportable_id: review.id,
    reportable_type: review.type
  ).first_or_create(
    content: Faker::LoremCN.words(10).join
  )

  printf '.'
end

puts ''
