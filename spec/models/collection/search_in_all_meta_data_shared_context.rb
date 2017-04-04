RSpec.shared_context 'search in all meta data shared context' do
  let(:collection_1) do
    collection = \
      FactoryGirl.create(:collection,
                         get_metadata_and_previews: true)
    FactoryGirl.create(:meta_datum_text,
                       value: 'gaura nitai bol',
                       collection: collection)
    collection
  end

  let(:collection_2) do
    collection = \
      FactoryGirl.create(:collection,
                         get_metadata_and_previews: true)
    FactoryGirl.create(:meta_datum_text_date,
                       value: 'gaura nitai bol',
                       collection: collection)
    collection
  end

  let(:collection_3) do
    collection = \
      FactoryGirl.create(:collection,
                         get_metadata_and_previews: true)
    FactoryGirl.create(:meta_datum_keywords,
                       keywords: [FactoryGirl.create(:keyword),
                                  FactoryGirl.create(:keyword,
                                                     term: 'gaura nitai bol')],
                       collection: collection)
    collection
  end

  let(:collection_4) do
    collection = \
      FactoryGirl.create(:collection,
                         get_metadata_and_previews: true)
    FactoryGirl.create \
      :meta_datum_people,
      people: [FactoryGirl.create(:person),
               FactoryGirl.create(:person,
                                  first_name: 'gaura',
                                  last_name: 'nitai bol')],
      collection: collection
    collection
  end

  let(:collection_5) do
    collection = \
      FactoryGirl.create(:collection,
                         get_metadata_and_previews: true)
    FactoryGirl.create(
      :meta_datum_people,
      people: [FactoryGirl.create(:person),
               FactoryGirl.create(:person, last_name: 'gaura nitai bol')],
      collection: collection)
    collection
  end

  let(:collection_6) do
    collection = \
      FactoryGirl.create(:collection,
                         get_metadata_and_previews: true)
    FactoryGirl.create(
      :meta_datum_keywords,
      keywords: [
        FactoryGirl.create(:keyword, :license),
        FactoryGirl.create(:keyword, :license, :license, term: 'gaura nitai bol')],
      collection: collection)
    collection
  end
end
