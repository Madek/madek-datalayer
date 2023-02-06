FactoryBot.define do

  factory :delegation do |n|
    name { Faker::Lorem.words(number: 7).join(' ') }
    description { Faker::Lorem.paragraph }
    admin_comment { Faker::Lorem.sentence }

    trait :with_media_entries do
      transient do
        entries_amount { 2 }
      end

      after(:create) do |delegation, evaluator|
        create_list(:media_entry,
                    evaluator.entries_amount,
                    responsible_user: nil,
                    responsible_delegation: delegation)
      end
    end

    trait :with_collections do
      transient do
        collections_amount { 2 }
      end

      after(:create) do |delegation, evaluator|
        create_list(:collection,
                    evaluator.collections_amount,
                    responsible_user: nil,
                    responsible_delegation: delegation)
      end
    end
  end

end
