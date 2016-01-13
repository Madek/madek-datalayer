RSpec.shared_context 'search in all meta data shared context' do
  let(:media_entry_1) do
    media_entry = \
      FactoryGirl.create(:media_entry,
                         get_metadata_and_previews: true)
    meta_datum_text = FactoryGirl.create(:meta_datum_text,
                                         value: 'gaura nitai bol')
    media_entry.meta_data << meta_datum_text
    media_entry
  end

  let(:media_entry_2) do
    media_entry = \
      FactoryGirl.create(:media_entry,
                         get_metadata_and_previews: true)
    meta_datum_text_date = FactoryGirl.create(:meta_datum_text_date,
                                              value: 'gaura nitai bol')
    media_entry.meta_data << meta_datum_text_date
    media_entry
  end

  let(:media_entry_3) do
    media_entry = \
      FactoryGirl.create(:media_entry,
                         get_metadata_and_previews: true)
    meta_datum_keywords = \
      FactoryGirl.create(:meta_datum_keywords,
                         keywords: [FactoryGirl.create(:keyword),
                                    FactoryGirl.create(:keyword,
                                                       term: 'gaura nitai bol')])
    media_entry.meta_data << meta_datum_keywords
    media_entry
  end

  let(:media_entry_4) do
    media_entry = \
      FactoryGirl.create(:media_entry,
                         get_metadata_and_previews: true)
    meta_datum_people = \
      FactoryGirl.create \
        :meta_datum_people,
        people: [FactoryGirl.create(:person),
                 FactoryGirl.create(:person,
                                    searchable: 'gaura nitai bol')]
    media_entry.meta_data << meta_datum_people
    media_entry
  end

  let(:media_entry_5) do
    media_entry = \
      FactoryGirl.create(:media_entry,
                         get_metadata_and_previews: true)
    # don't use searchable for group, it has an after_save hook!
    meta_datum_groups = \
      FactoryGirl.create(:meta_datum_groups,
                         groups: [FactoryGirl.create(:group),
                                  FactoryGirl.create(:group,
                                                     name: 'gaura nitai bol')])
    media_entry.meta_data << meta_datum_groups
    media_entry
  end

  let(:media_entry_6) do
    media_entry = \
      FactoryGirl.create(:media_entry,
                         get_metadata_and_previews: true)
    meta_datum_licenses = \
      FactoryGirl.create(:meta_datum_licenses,
                         licenses: [FactoryGirl.create(:license),
                                    FactoryGirl.create(:license,
                                                       label: 'gaura nitai bol')])
    media_entry.meta_data << meta_datum_licenses
    media_entry
  end
end
