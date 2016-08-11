FactoryGirl.define do

  factory :group do
    name { Faker::Lorem.words(3).join(' ') }

    trait :with_user do
      after(:create) do |group|
        group.users << create(:user)
      end
    end
  end

  factory :institutional_group do

    name { Faker::Lorem.words(3).join(' ') }
    institutional_group_name { Faker::Lorem.words(3).join(' ') }
    type { 'InstitutionalGroup' }

    trait :with_user do
      after(:create) do |group|
        group.users << create(:user)
      end
    end
  end
end
