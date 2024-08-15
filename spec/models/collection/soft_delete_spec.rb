require 'spec_helper'
require Rails.root.join('spec', 'models', 'collection', 'search_in_all_meta_data_shared_context.rb')

def clear_db
  Keyword.delete_all
  MetaDatum.delete_all
  Collection.delete_all
end

describe Collection do
  context 'fetch collections' do

    # before :each do
    #   clear_db
    # end

    it 'includes future deleted_at collections as valid' do
      collection = create(:collection)
      collection_1 = create(:collection)
      collection_2 = create(:collection, deleted_at: Time.now + 1.day)

      [collection_1, collection_2].each do |c|
        collection.collections << c
      end

      expect(collection.collections.count).to eq(2)
    end

    it 'excludes collections deleted in the past' do
      collection = create(:collection)
      collection_1 = create(:collection, deleted_at: Time.now)
      collection_2 = create(:collection, deleted_at: Time.now - 1.day)

      [collection_1, collection_2].each do |c|
        collection.collections << c
      end

      expect(collection.collections.count).to eq(0)
    end

    it 'includes future deleted_at and valid collections, excluding past deleted_at' do
      collection = create(:collection)
      collection_1 = create(:collection, deleted_at: Time.now - 1.day)
      collection_2 = create(:collection, deleted_at: Time.now + 1.day)
      collection_3 = create(:collection)

      [collection_1, collection_2, collection_3].each do |c|
        collection.collections << c
      end

      expect(collection.collections.count).to eq(2)
    end

    it "deletes entries if deleted_at-ts is older than or equal to 6 months" do
      [6, 7].each do |months_ago|
        collection = create(:collection)
        collection_2 = create(:collection, deleted_at: months_ago.months.ago)

        meta_datum_keywords = FactoryBot.create(:meta_datum_keywords,
                                                keywords: [FactoryBot.create(:keyword),
                                                           FactoryBot.create(:keyword, term: 'gaura nitai bol')])
        collection_2.meta_data << meta_datum_keywords
        collection.collections << collection_2

        collection_2_id = collection_2.id
        meta_data_id = collection_2.meta_data.first!.id

        expect(collection_2.meta_data.count).to eq(1)
        expect(Collection.unscoped.where(id: collection_2_id)).to be
        expect(MetaDatum.find_by(id: meta_data_id)).to be

        Collection.delete_soft_deleted

        expect(Collection.unscoped.where(id: collection_2_id).count).to eq(0)
        expect(MetaDatum.find_by(id: meta_data_id)).not_to be

        clear_db
      end
    end

    it "doesn't delete entries if deleted_at is less than 6 months ago" do
      [4, 5].each do |months_ago|
        collection = create(:collection)
        collection_2 = create(:collection, deleted_at: months_ago.months.ago)

        meta_datum_keywords = FactoryBot.create(:meta_datum_keywords,
                                                keywords: [FactoryBot.create(:keyword),
                                                           FactoryBot.create(:keyword, term: 'gaura nitai bol')])
        collection_2.meta_data << meta_datum_keywords
        collection.collections << collection_2

        collection_2_id = collection_2.id
        meta_data_id = collection_2.meta_data.first!.id

        expect(collection_2.meta_data.count).to eq(1)
        expect(Collection.unscoped.where(id: collection_2_id)).to be
        expect(MetaDatum.find_by(id: meta_data_id)).to be

        Collection.delete_soft_deleted

        expect(Collection.unscoped.where(id: collection_2_id).count).to eq(1)
        expect(MetaDatum.find_by(id: meta_data_id)).to be

        clear_db
      end
    end
  end
end
