puts 'Create comments '
(200 - Comment.count).times do |content|
  Comment.create(
    writer_id: User.order('RANDOM()').first.id,
    user_id: User.order('RANDOM()').first.id,
    content:  Faker::LoremCN.paragraph
  )
  printf '.'
end

puts ''
