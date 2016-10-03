require 'spec_helper'

describe MetaDatum::Keywords do
  context 'created_by' do
    it 'validates presence of' do
      vocab = create(:vocabulary)
      meta_key = create(:meta_key_keywords,
                        vocabulary: vocab,
                        id: "#{vocab.id}:#{Faker::Lorem.characters(10)}")
      expect { create(:meta_datum_keywords, created_by: nil, meta_key: meta_key) }
        .to raise_error /created_by in table meta_data may not be null/
    end
  end
end
