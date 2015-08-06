require 'spec_helper'
require 'spec_helper_no_tx'

describe Arcs::CollectionMediaEntryArc do
  context 'check uniqueness of cover for particular collection' do
    it 'raises for INSERT' do
      collection = create(:collection)
      create(:collection_media_entry_arc, collection: collection, cover: true)

      expect do
        create(:collection_media_entry_arc,
               collection: collection,
               cover: true)
      end.to raise_error(/there exists already a cover/i)

      expect(described_class.where(collection: collection, cover: true).count)
        .to be == 1
    end

    it 'raises for UPDATE' do
      collection = create(:collection)
      create(:collection_media_entry_arc, collection: collection, cover: true)
      arc = create(:collection_media_entry_arc,
                   collection: collection,
                   cover: false)

      expect { arc.update_attributes(cover: true) }
        .to raise_error(/there exists already a cover/i)

      expect(described_class.where(collection: collection, cover: true).count)
        .to be == 1
    end
  end
end
