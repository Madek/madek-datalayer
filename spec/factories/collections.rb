FactoryBot.define do

  factory :collection do
    association :responsible_user, factory: :user
    association :creator, factory: :user

    before(:create) do |collection|
      # we need app_setting for required context keys validation
      AppSetting.first.presence || create(:app_setting)
    end

    created_at { Time.now }

    factory :collection_with_title, class: 'Collection' do
      transient do
        title { Faker::Lorem.words.join(' ') }
      end

      after(:create) do |collection, evaluator|
        create_list(
          :meta_datum_title,
          1,
          collection: collection,
          string: evaluator.title,
          created_by: evaluator.creator
        )
      end
    end
  end

end
