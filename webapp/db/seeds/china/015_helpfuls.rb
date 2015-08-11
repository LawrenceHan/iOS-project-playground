puts 'Creating helpfuls '

(500 - Helpful.count).times do |x|
  Helpful.where(
    review_id: Review.order('RANDOM()').first.id,
    user_id: User.order('RANDOM()').first.id
  ).first_or_create

  printf '.'
end

puts ''
