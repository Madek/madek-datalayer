FactoryGirl.define do

  factory :group do
    name { Faker::Lorem.words(3).join(' ') }

    trait :with_user do
      after(:create) do |group|
        group.users << create(:user)
      end
    end

    factory :institutional_group do
      institutional_group_name { Faker::Lorem.words(3).join(' ') }
      type 'InstitutionalGroup'
    end

    factory :authentication_group do
      type 'AuthenticationGroup'
    end
  end

end
