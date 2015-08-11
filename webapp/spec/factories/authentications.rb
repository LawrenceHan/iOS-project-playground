# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :authentication do
    user
    uid '1234567890'
    token 'abcdefg'
    token_secret 'gfedcba'
  end

  factory :twitter_authentication, parent: :authentication do
    provider 'twitter'
  end
end
