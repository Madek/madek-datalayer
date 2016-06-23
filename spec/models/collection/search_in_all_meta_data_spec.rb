require 'spec_helper'
require Rails.root.join('spec',
                        'models',
                        'collection',
                        'search_in_all_meta_data_shared_context.rb')

describe Collection do
  include_context 'search in all meta data shared context'

  context 'search in all meta data' do
    it 'is successful' do
      # force evaluation
      expected_result = [collection_1,
                         collection_2,
                         collection_3,
                         collection_4,
                         collection_5,
                         collection_6]

      filtered_collections = \
        Collection.filter_by(meta_data: [{ key: 'any', match: 'nitai' }])

      expect(filtered_collections.count).to be == 6
      expected_result.each do |me|
         expect(filtered_collections).to include me
      end
    end

    it 'chains properly with other filter' do
      vocabulary = create(:vocabulary, id: 'filter')
      meta_datum_text = \
        create(:meta_datum_text,
               meta_key: \
                 create(:meta_key_text,
                        id: "#{vocabulary.id}:#{Faker::Lorem.characters(20)}",
                        vocabulary: vocabulary),
               collection: collection_1)

      filtered_collections = \
        Collection
          .filter_by(search: 'nitai')
          .filter_by(meta_data: [{ key: meta_datum_text.meta_key_id,
                                   match: meta_datum_text.string }])

      expect(filtered_collections).to include collection_1
      expect(filtered_collections.count).to be == 1
    end
  end
end
