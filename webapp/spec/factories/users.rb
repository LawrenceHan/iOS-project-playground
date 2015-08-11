# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@test.com" }
    password '12345678'
    password_confirmation '12345678'
    sequence(:phone) { |n|  (12345678900 + n).to_s }
    sms_token 'test'
  end
end
