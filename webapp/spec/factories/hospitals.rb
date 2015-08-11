# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :hospital do
  end

  factory :cegedim_hospital, class: Cegedim::Hospital do
  end

end
