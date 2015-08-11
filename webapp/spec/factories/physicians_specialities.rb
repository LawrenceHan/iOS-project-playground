# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :physicians_speciality do
    physician
    speciality
  end
end
