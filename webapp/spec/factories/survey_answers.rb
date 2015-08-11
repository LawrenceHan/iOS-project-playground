# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :survey_answer do
    survey_question nil
    value "MyString"
  end
end
