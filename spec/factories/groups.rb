FactoryBot.define do

  factory :group do
    name { Faker::Lorem.words(number: 7).join(' ') }

    trait :with_user do
      after(:create) do |group|
        group.users << create(:user)
      end
    end

    factory :institutional_group do
      type { 'InstitutionalGroup' }
      institutional_id { SecureRandom.uuid }
    end

    factory :authentication_group do
      type { 'AuthenticationGroup' }
    end
  end

end
