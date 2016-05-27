FactoryGirl.define do
  factory :usage_terms do
    title 'Nutzungsbedingungen'
    version '1.0'
    intro { Faker::Lorem.words.join(' ') }
    body { Faker::Lorem.words.join(' ') }
  end
end
