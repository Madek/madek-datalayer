FactoryGirl.define do
  factory :api_client do
    login { Faker::Lorem.words(5).shuffle.join('_').slice(0, 20) }
    description { Faker::Lorem.words(10).join(' ') }
    password 'securepassword'
    user { User.find_random || (FactoryGirl.create :user) }
  end
end
