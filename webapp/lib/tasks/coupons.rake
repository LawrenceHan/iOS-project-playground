namespace :coupons do
  desc 'import from cardinal health'
  task :import_from_cardinal_health => :environment do
    docs = File.read(Rails.root.join('spec/tasks/cardinal_health_coupon_codes.csv'))
    CSV.parse(docs, headers: true) do |row|
      coupon = Coupon.new
      coupon.code = row['号码']
      coupon.source = 'cardinal_health'
      coupon.save
    end
  end
end
