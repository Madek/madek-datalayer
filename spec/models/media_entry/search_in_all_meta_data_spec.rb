require 'spec_helper'
require Rails.root.join('spec',
                        'models',
                        'media_entry',
                        'search_in_all_meta_data_shared_context.rb')

describe MediaEntry do
  include_context 'search in all meta data shared context'

  context 'search in all meta data' do
    it 'is successful' do
      filtered_media_entries = \
        MediaEntry.filter_by(meta_data: [{ key: 'any', match: 'nitai' }])

      [media_entry_1,
       media_entry_2,
       media_entry_3,
       media_entry_4,
       media_entry_5,
       media_entry_6].each do |me|
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
      media_entry_1.meta_data << meta_datum_text

      filtered_media_entries = \
        MediaEntry
          .filter_by(search: 'nitai')
          .filter_by(meta_data: [{ key: meta_datum_text.meta_key_id,
                                   match: meta_datum_text.string }])

      expect(filtered_media_entries).to include media_entry_1
      expect(filtered_media_entries.count).to be == 1
    end
  end
end
