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

end
