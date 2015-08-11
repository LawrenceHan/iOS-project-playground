# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :survey_question do
    survey nil
    title "MyString"
    possible_options ""
  end
end
