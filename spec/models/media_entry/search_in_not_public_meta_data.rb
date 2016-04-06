require 'spec_helper'
require Rails.root.join('spec',
                        'models',
                        'media_entry',
                        'search_in_not_public_meta_data_shared_context.rb')

describe MediaEntry do
  context 'applying a meta data filter on a not public meta key ' \
          'without permissions' do
    include_context 'meta data from not public vocabulary shared context'

    it ':key raises an error' do
      meta_datum_text # just force evaluation
      filter = { meta_data: [{ 'key': meta_key.id }] }
      expect { MediaEntry.filter_by(filter) }
        .to raise_error /not viewable meta_key/i
    end

    it ':not_key returns an empty result' do
      meta_datum_text # just force evaluation
      filter = { meta_data: [{ 'not_key': "#{Faker::Lorem.word}" }] }
      filtered_media_entries = MediaEntry.filter_by(filter)
      expect(filtered_media_entries.count).to be == 0
    end

    it ':key \'any\' returns an empty result' do
      meta_datum_text # just force evaluation
      filter = { meta_data: [{ 'key': 'any', match: meta_datum_text.string }] }
      filtered_media_entries = MediaEntry.filter_by(filter)
      expect(filtered_media_entries.count).to be == 0
    end

    it ':key \'any\' and :type \'MetaDatum::Text\' returns an empty result' do
      meta_datum_text # just force evaluation
      filter = { meta_data: [{ 'key': 'any',
                               type: 'MetaDatum::Text',
                               match: meta_datum_text.string }] }
      filtered_media_entries = MediaEntry.filter_by(filter)
      expect(filtered_media_entries.count).to be == 0
    end
  end
end
