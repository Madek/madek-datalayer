FactoryBot.define do
  factory :usage_terms do
    title { Faker::Book.title }
    version { Faker::Lorem.sentence }
    intro { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraph }
  end
end
