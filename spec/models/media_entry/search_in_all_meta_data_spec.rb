require 'spec_helper'

describe MediaEntry do
  before :context do
    @media_entry_1 = create(:media_entry,
                            get_metadata_and_previews: true)
    @media_entry_2 = create(:media_entry,
                            get_metadata_and_previews: true)
    @media_entry_3 = create(:media_entry,
                            get_metadata_and_previews: true)
    @media_entry_4 = create(:media_entry,
                            get_metadata_and_previews: true)
    @media_entry_5 = create(:media_entry,
                            get_metadata_and_previews: true)
    @media_entry_6 = create(:media_entry,
                            get_metadata_and_previews: true)

    # META DATA  ##########################################################
    meta_datum_text = create(:meta_datum_text,
                             value: 'gaura nitai bol')
    @media_entry_1.meta_data << meta_datum_text

    meta_datum_text_date = create(:meta_datum_text_date,
                                  value: 'gaura nitai bol')
    @media_entry_2.meta_data << meta_datum_text_date

    meta_datum_keywords = \
      create(:meta_datum_keywords,
             keywords: [create(:keyword),
                        create(:keyword,
                               term: 'gaura nitai bol')])
    @media_entry_3.meta_data << meta_datum_keywords

    meta_datum_people = \
      create(:meta_datum_people,
             people: [create(:person),
                      create(:person,
                             searchable: 'gaura nitai bol')])
    @media_entry_4.meta_data << meta_datum_people

    # don't use searchable for group, it has an after_save hook!
    meta_datum_groups = \
      create(:meta_datum_groups,
             groups: [create(:group),
                      create(:group,
                             name: 'gaura nitai bol')])
    @media_entry_5.meta_data << meta_datum_groups

    meta_datum_licenses = \
      create(:meta_datum_licenses,
             licenses: [create(:license),
                        create(:license,
                               label: 'gaura nitai bol')])
    @media_entry_6.meta_data << meta_datum_licenses

    20.times do
      create \
        [:media_entry_with_image_media_file,
         :media_entry_with_audio_media_file].sample,
        :fat
    end
  end

  context 'search in all meta data' do
    it 'is successful' do
      filtered_media_entries = \
        MediaEntry.filter_by(meta_data: [{ key: 'any', match: 'nitai' }])

      [@media_entry_1,
       @media_entry_2,
       @media_entry_3,
       @media_entry_4,
       @media_entry_5,
       @media_entry_6].each do |me|
         expect(filtered_media_entries).to include me
       end
      expect(filtered_media_entries.count).to be == 6
    end

    it 'chains properly with other filter' do
      vocabulary = create(:vocabulary, id: 'filter')
      meta_datum_text = \
        create(:meta_datum_text,
               meta_key: \
                 create(:meta_key_text,
                        id: "#{vocabulary.id}:#{Faker::Lorem.characters(20)}",
                        vocabulary: vocabulary))
      @media_entry_1.meta_data << meta_datum_text

      filtered_media_entries = \
        MediaEntry
          .filter_by(search: 'nitai')
          .filter_by(meta_data: [{ key: meta_datum_text.meta_key_id,
                                   match: meta_datum_text.string }])

      expect(filtered_media_entries).to include @media_entry_1
      expect(filtered_media_entries.count).to be == 1
    end
  end
end
