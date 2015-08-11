# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :departments_hospital do
    hospital
    department
  end
end
