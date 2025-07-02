FactoryBot.define do

  factory :media_entry do
    created_at { Time.now }

    # factory "publishes" by default, set to false to test publishing itself
    is_published { true }

    association :responsible_user, factory: :user
    association :creator, factory: :user

    before :create do |md|
      app_setting = AppSetting.first.presence || create(:app_setting)
      # NOTE: default in personas for historical reasons,
      # needs to be disabled when using factories
      app_setting.update!(contexts_for_entry_validation: [])
    end

    factory :media_entry_with_title do
      transient do
        title { Faker::Lorem.words.join(' ') }
      end

      after(:create) do |media_entry, evaluator|
        create_list(
          :meta_datum_title,
          1,
          media_entry: media_entry,
          string: evaluator.title,
          created_by: evaluator.creator
        )
      end
    end

    factory :media_entry_with_image_media_file do
      after(:create) do |me|
        FactoryBot.create :media_file_for_image, media_entry: me
      end
    end

    factory :media_entry_with_audio_media_file do
      after(:create) do |me|
        FactoryBot.create :media_file_for_audio, media_entry: me
      end
    end

    factory :media_entry_with_video_media_file do
      after(:create) do |me|
        FactoryBot.create :media_file_for_movie, media_entry: me
      end
    end

    factory :media_entry_with_document_media_file do
      after(:create) do |me|
        FactoryBot.create :media_file_for_document, media_entry: me
      end
    end

    factory :media_entry_with_other_media_file do
      after(:create) do |me|
        FactoryBot.create :media_file_for_other, media_entry: me
      end
    end
  end

  trait :fat do
    after(:create) do |me|
      vocabulary = create(:vocabulary,
                          id: Faker::Lorem.characters(number: 10))

      rand(1..3).times do
        me.meta_data << \
          create(:meta_datum_text,
                 meta_key: \
                 create(:meta_key_text,
                        id: "#{vocabulary.id}:#{Faker::Lorem.characters(number: 20)}",
                        vocabulary: vocabulary))
      end
      rand(1..3).times do
        me.meta_data << \
          create(:meta_datum_text_date,
                 meta_key: \
                 create(:meta_key_text_date,
                        id: "#{vocabulary.id}:#{Faker::Lorem.characters(number: 20)}",
                        vocabulary: vocabulary))
      end
      rand(1..3).times do
        me.meta_data << \
          create(:meta_datum_json,
                 meta_key: \
                 create(:meta_key_json,
                        id: "#{vocabulary.id}:#{Faker::Lorem.characters(number: 20)}",
                        vocabulary: vocabulary))
      end
      rand(1..3).times do
        me.meta_data << \
          create(:meta_datum_keywords,
                 meta_key: \
                   create(:meta_key_keywords,
                          id: "#{vocabulary.id}:#{Faker::Lorem.characters(number: 20)}",
                          vocabulary: vocabulary))
      end
      rand(1..3).times do
        me.meta_data << \
          create(:meta_datum_people,
                 meta_key: \
                   create(:meta_key_people,
                          id: "#{vocabulary.id}:#{Faker::Lorem.characters(number: 20)}",
                          vocabulary: vocabulary))
      end

      rand(1..3).times do
        me.user_permissions << create(:media_entry_user_permission,
                                      user: create(:user))
      end
      rand(1..3).times do
        me.group_permissions << create(:media_entry_group_permission,
                                       group: create(:group))
      end
      rand(1..3).times do
        me.api_client_permissions << create(:media_entry_api_client_permission,
                                            api_client: create(:api_client))
      end
    end
  end
end
