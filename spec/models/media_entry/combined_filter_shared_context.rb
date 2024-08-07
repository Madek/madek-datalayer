RSpec.shared_context 'meta data shared context' do
  let(:vocabulary) { FactoryBot.create(:vocabulary, id: 'filter') }
  let(:responsible_user) { FactoryBot.create(:user) }
  let(:entrusted_user) { FactoryBot.create(:user) }
  let(:entrusted_group) { FactoryBot.create(:group) }
  let(:not_meta_key) do
    FactoryBot.create(:meta_key_keywords,
                       id: "#{vocabulary.id}:#{Faker::Lorem.characters(number: 20)}",
                       vocabulary: vocabulary)
  end
  let (:media_entry) do
    media_entry = FactoryBot.create(:media_entry_with_image_media_file,
                                     get_metadata_and_previews: 'true',
                                     responsible_user: responsible_user)
    media_entry.user_permissions << \
      FactoryBot.create(:media_entry_user_permission,
                         get_metadata_and_previews: 'true',
                         user: entrusted_user)
    media_entry.group_permissions << \
      FactoryBot.create(:media_entry_group_permission,
                         get_metadata_and_previews: 'true',
                         group: entrusted_group)
    media_entry
  end

  # MEDIA FILE SPECS ####################################################
  let(:media_files_1) do
    [{ key: 'content_type',
       value: media_entry.media_file.content_type },
     { key: 'uploader_id',
       value: media_entry.media_file.uploader_id }]
  end
  let(:media_files_2) do
    [{ key: 'extension',
       value: media_entry.media_file.extension }]
  end

  # META DATA  ##########################################################
  let(:meta_datum_text) do
    meta_datum_text = FactoryBot.create(:meta_datum_text,
                                         value: 'a par tial match')
    media_entry.meta_data << meta_datum_text
    meta_datum_text
  end

  let(:meta_datum_keywords_1) do
    meta_datum_keywords_1 = \
      FactoryBot.create \
        :meta_datum_keywords,
        meta_key: \
        FactoryBot.create(:meta_key_keywords,
                           id: "#{vocabulary.id}:#{Faker::Lorem.characters(number: 20)}",
                           vocabulary: vocabulary)
    media_entry.meta_data << meta_datum_keywords_1
    meta_datum_keywords_1
  end

  let(:meta_datum_keywords_2) do
    meta_datum_keywords_2 = \
      FactoryBot.create \
        :meta_datum_keywords,
        meta_key: \
        FactoryBot.create(:meta_key_keywords,
                           id: "#{vocabulary.id}:#{Faker::Lorem.characters(number: 20)}",
                           vocabulary: vocabulary)
    media_entry.meta_data << meta_datum_keywords_2
    meta_datum_keywords_2
  end

  let(:meta_datum_keywords_licenses) do
    meta_key = MetaKey.find_by(id: 'test:licenses') \
             || FactoryBot.create(:meta_key_keywords_license)
    FactoryBot.create(
      :meta_datum_keywords,
      media_entry: media_entry,
      meta_key: meta_key,
      keywords: [FactoryBot.create(:keyword, :license)])
  end

  let(:meta_datum_people) do
    meta_datum_people = FactoryBot.create(:meta_datum_people)
    media_entry.meta_data << meta_datum_people
    meta_datum_people
  end

  let(:meta_data_1) do
    [{ key: meta_datum_text.meta_key_id,
       match: 'par tial' },
     { key: meta_datum_keywords_1.meta_key_id,
       value: meta_datum_keywords_1.value.sample.id },
     { key: meta_datum_keywords_licenses.meta_key.id },
     { not_key: not_meta_key.id }]
  end

  let(:meta_data_2) do
    [{ key: meta_datum_people.meta_key_id,
       value: meta_datum_people.value.sample.id },
     { key: 'any',
       type: meta_datum_keywords_2.type,
       value: meta_datum_keywords_2.value.sample.id }]
  end

  # PERMISSIONS SPECS ###################################################
  let(:permissions_1) do
    [{ key: 'responsible_user',
       value: responsible_user.id },
     { key: 'public',
       value: 'true' },
     { key: 'entrusted_to_user',
       value: entrusted_user.id }]
  end
  let(:permissions_2) do
    [{ key: 'entrusted_to_group',
       value: entrusted_group.id }]
  end
end
