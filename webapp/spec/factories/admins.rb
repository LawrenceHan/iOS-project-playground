# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :admin do
    email 'jonathan.dairion@cegedim.com'
    password '123456'
    password_confirmation '123456'
  end
end
