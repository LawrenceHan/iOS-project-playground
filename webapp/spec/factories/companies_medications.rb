# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :companies_medication do
    company
    medication
  end
end
