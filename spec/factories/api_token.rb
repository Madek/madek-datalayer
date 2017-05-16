FactoryGirl.define do

  factory :api_token do
    user { create(:user) }
    description { Faker::Hacker::phrases.sample }
  end

end
