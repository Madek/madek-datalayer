FactoryBot.define do
  factory :api_client do
    login { Faker::Lorem.words(number: 5).shuffle.join('_').slice(0, 20) }
    description { Faker::Lorem.words(number: 10).join(' ') }
    password { 'securepassword' }
    user { User.find_random || (FactoryBot.create :user) }
  end
end
