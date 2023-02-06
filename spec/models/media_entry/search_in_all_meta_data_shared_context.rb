RSpec.shared_context 'search in all meta data shared context' do
  let(:media_entry_1) do
    media_entry = \
      FactoryBot.create(:media_entry,
                         get_metadata_and_previews: true)
    meta_datum_text = FactoryBot.create(:meta_datum_text,
                                         value: 'gaura nitai bol')
    media_entry.meta_data << meta_datum_text
    media_entry
  end

  let(:media_entry_2) do
    media_entry = \
      FactoryBot.create(:media_entry,
                         get_metadata_and_previews: true)
    meta_datum_text_date = FactoryBot.create(:meta_datum_text_date,
                                              value: 'gaura nitai bol')
    media_entry.meta_data << meta_datum_text_date
    media_entry
  end

  let(:media_entry_3) do
    media_entry = \
      FactoryBot.create(:media_entry,
                         get_metadata_and_previews: true)
    meta_datum_keywords = \
      FactoryBot.create(:meta_datum_keywords,
                         keywords: [FactoryBot.create(:keyword),
                                    FactoryBot.create(:keyword,
                                                       term: 'gaura nitai bol')])
    media_entry.meta_data << meta_datum_keywords
    media_entry
  end

  let(:media_entry_4) do
    media_entry = \
      FactoryBot.create(:media_entry,
                         get_metadata_and_previews: true)
    meta_datum_people = \
      FactoryBot.create \
        :meta_datum_people,
        people: [FactoryBot.create(:person),
                 FactoryBot.create(:person,
                                    first_name: 'gaura',
                                    last_name: 'nitai bol')]
    media_entry.meta_data << meta_datum_people
    media_entry
  end

  let(:media_entry_6) do
    media_entry = \
      FactoryBot.create(
        :media_entry, get_metadata_and_previews: true)
    meta_key = MetaKey.find_by(id: 'test:licenses') \
             || FactoryBot.create(:meta_key_keywords_license)
    licenses = FactoryBot.create(
      :meta_datum_keywords,
      meta_key: meta_key,
      keywords: [
        FactoryBot.create(:keyword, :license),
        FactoryBot.create(:keyword, :license, term: 'gaura nitai bol')])
    media_entry.meta_data << licenses
    media_entry
  end
end
