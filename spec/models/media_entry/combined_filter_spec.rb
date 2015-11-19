require 'spec_helper'

describe MediaEntry do
  it 'combines filters properly' do
    vocabulary = create(:vocabulary, id: 'filter')
    responsible_user = create(:user)
    entrusted_user = create(:user)
    entrusted_group = create(:group)
    not_meta_key = create(:meta_key_keywords,
                          id: "#{vocabulary.id}:#{Faker::Lorem.characters(20)}",
                          vocabulary: vocabulary)
    @media_entry = create(:media_entry_with_image_media_file,
                          get_metadata_and_previews: true,
                          responsible_user: responsible_user)
    @media_entry.user_permissions << create(:media_entry_user_permission,
                                            get_metadata_and_previews: true,
                                            user: entrusted_user)
    @media_entry.group_permissions << create(:media_entry_group_permission,
                                             get_metadata_and_previews: true,
                                             group: entrusted_group)

    # MEDIA FILE SPECS ####################################################
    media_files_1 = [{ key: 'content_type',
                       value: @media_entry.media_file.content_type },
                     { key: 'uploader_id',
                       value: @media_entry.media_file.uploader_id }]
    media_files_2 = [{ key: 'extension',
                       value: @media_entry.media_file.extension }]

    # META DATA  ##########################################################
    meta_datum_text = create(:meta_datum_text,
                             value: 'a par tial match')
    @media_entry.meta_data << meta_datum_text

    meta_datum_keywords_1 = \
      create(:meta_datum_keywords,
             meta_key: \
               create(:meta_key_keywords,
                      id: "#{vocabulary.id}:#{Faker::Lorem.characters(20)}",
                      vocabulary: vocabulary))
    @media_entry.meta_data << meta_datum_keywords_1

    meta_datum_keywords_2 = \
      create(:meta_datum_keywords,
             meta_key: \
               create(:meta_key_keywords,
                      id: "#{vocabulary.id}:#{Faker::Lorem.characters(20)}",
                      vocabulary: vocabulary))
    @media_entry.meta_data << meta_datum_keywords_2

    meta_datum_people = create(:meta_datum_people)
    @media_entry.meta_data << meta_datum_people

    meta_datum_licenses = create(:meta_datum_licenses)
    @media_entry.meta_data << meta_datum_licenses

    meta_data_1 = [{ key: meta_datum_text.meta_key_id,
                     match: 'par tial' },
                   { key: meta_datum_keywords_1.meta_key_id,
                     value: meta_datum_keywords_1.value.sample.id },
                   { key: meta_datum_licenses.meta_key.id },
                   { not_key: not_meta_key.id }]
    meta_data_2 = [{ key: meta_datum_people.meta_key_id,
                     value: meta_datum_people.value.sample.id },
                   { key: 'any',
                     type: meta_datum_keywords_2.type,
                     value: meta_datum_keywords_2.value.sample.id }]

    # PERMISSIONS SPECS ###################################################
    permissions_1 = [{ key: 'responsible_user',
                       value: responsible_user.id },
                     { key: 'public',
                       value: true },
                     { key: 'entrusted_to_user',
                       value: entrusted_user.id }]
    permissions_2 = [{ key: 'entrusted_to_group',
                       value: entrusted_group.id }]

    20.times do
      create \
        [:media_entry_with_image_media_file,
         :media_entry_with_audio_media_file].sample,
        :fat
    end

    filtered_media_entries = \
      MediaEntry
        .filter_by(meta_data: meta_data_1,
                   media_files: media_files_1,
                   permissions: permissions_1)
        .filter_by(meta_data: meta_data_2,
                   media_files: media_files_2,
                   permissions: permissions_2)

    expect(filtered_media_entries.count).to be == 1
    expect(filtered_media_entries.first).to be == @media_entry
  end
end
