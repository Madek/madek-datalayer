FactoryBot.define do
  factory :notification_case do
    label { Faker::Lorem.words(number: 100).sample }
    description { Faker::Lorem.sentence }
  end
end
