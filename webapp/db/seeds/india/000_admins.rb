puts "========================================"
puts "Create Indian data"
puts "========================================"
puts "Create admin ..."
Admin.where(email: 'admin@ekohe.com').first_or_create!(password: 'admin', password_confirmation: 'admin')
