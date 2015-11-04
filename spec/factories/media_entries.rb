FactoryGirl.define do

  factory :media_entry do
    created_at { Time.now }

    # factory "publishes" by default, set to false to test publishing itself
    is_published true

    association :responsible_user, factory: :user
    association :creator, factory: :user

    factory :media_entry_with_title do
      transient do
        title { Faker::Lorem.words.join(' ') }
      end

      after(:create) do |media_entry, evaluator|
        create_list(
          :meta_datum_title,
          1,
          media_entry: media_entry,
          string: evaluator.title
        )
      end
    end

    factory :media_entry_with_image_media_file do
      after(:create) do |me|
        FactoryGirl.create :media_file_for_image, media_entry: me
      end
    end

    factory :media_entry_with_audio_media_file do
      after(:create) do |me|
        FactoryGirl.create :media_file_for_audio, media_entry: me
      end
    end
  end

  trait :fat do
    after(:create) do |me|
      vocabulary = create(:vocabulary,
                          id: Faker::Lorem.characters(10))

      rand(1..3).times do
        me.meta_data << \
          create(:meta_datum_text,
                 meta_key: \
                 create(:meta_key_text,
                        id: "#{vocabulary.id}:#{Faker::Lorem.characters(20)}",
                        vocabulary: vocabulary))
      end
      rand(1..3).times do
        me.meta_data << \
          create(:meta_datum_keywords,
                 meta_key: \
                   create(:meta_key_keywords,
                          id: "#{vocabulary.id}:#{Faker::Lorem.characters(20)}",
                          vocabulary: vocabulary))
      end
      rand(1..3).times do
        me.meta_data << \
          create(:meta_datum_people,
                 meta_key: \
                   create(:meta_key_people,
                          id: "#{vocabulary.id}:#{Faker::Lorem.characters(20)}",
                          vocabulary: vocabulary))
      end
      rand(1..3).times do
        me.meta_data << \
          create(:meta_datum_licenses,
                 meta_key: \
                   create(:meta_key_licenses,
                          id: "#{vocabulary.id}:#{Faker::Lorem.characters(20)}",
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
