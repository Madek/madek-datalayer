require 'spec_helper'
require 'spec_helper_no_tx'

def create_meta_datum
  FactoryBot.create :meta_datum_keywords
end

describe MetaDatum::Keywords do

  describe 'with a few keywords' do

    before :each do
      ActiveRecord::Base.transaction do
        @collection = FactoryBot.create :collection
        @meta_key_keywords = FactoryBot.create :meta_key_keywords
        @meta_datum = FactoryBot.create :meta_datum_keywords,
                                         collection: @collection,
                                         meta_key: @meta_key_keywords
      end
    end

    it 'deleting all keywords deletes the meta_datum' do
      expect(MetaDatum.find_by id: @meta_datum.id).to be
      expect(@meta_datum.keywords.count).to be >= 1
      @meta_datum.keywords.destroy_all
      expect(MetaDatum.find_by id: @meta_datum.id).not_to be
    end

  end

  describe 'creating an empty one' do

    before :each do
      @collection = FactoryBot.create :collection
      @meta_key_keywords = FactoryBot.create :meta_key_keywords
    end

    it 'will be deleted after closing the transaction' do

      ActiveRecord::Base.transaction do

        @meta_datum = FactoryBot.create :meta_datum_keywords,
                                         collection: @collection,
                                         meta_key: @meta_key_keywords,
                                         keywords: []

        expect(@meta_datum.keywords.count).to be == 0

        expect(MetaDatum.find_by id: @meta_datum.id).to be
      end

      expect(MetaDatum.find_by id: @meta_datum.id).not_to be

    end
  end
end
