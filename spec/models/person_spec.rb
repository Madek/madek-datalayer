require 'spec_helper'

describe Person do

  it 'usage count in meta data' do

    person_1_first_name = Faker::Lorem.characters(8)
    person_1 = FactoryGirl.create(:person, first_name: person_1_first_name)

    person_2_first_name = Faker::Lorem.characters(8)
    FactoryGirl.create(:person, first_name: person_2_first_name)

    media_entry = FactoryGirl.create(:media_entry)
    2.times do
      FactoryGirl.create(:meta_datum_people,
                         people: [person_1],
                         meta_key: FactoryGirl.create(
                           :meta_key,
                           meta_datum_object_type: 'MetaDatum::People',
                           allowed_people_subtypes: ['Person'],
                           id: "test:#{Faker::Lorem.characters(8)}"
                         ),
                         media_entry: media_entry,
                         collection: nil)
    end
    FactoryGirl.create(:meta_datum_people,
                       people: [person_1],
                       meta_key: FactoryGirl.create(
                         :meta_key,
                         meta_datum_object_type: 'MetaDatum::People',
                         allowed_people_subtypes: ['Person'],
                         id: "test:#{Faker::Lorem.characters(8)}"
                       ),
                       media_entry: FactoryGirl.create(:media_entry),
                       collection: nil)
    # ######################################################################
    # unpublished entry
    FactoryGirl.create(:meta_datum_people,
                       people: [person_1],
                       meta_key: FactoryGirl.create(
                         :meta_key,
                         meta_datum_object_type: 'MetaDatum::People',
                         allowed_people_subtypes: ['Person'],
                         id: "test:#{Faker::Lorem.characters(8)}"
                       ),
                       media_entry: FactoryGirl.create(:media_entry,
                                                       is_published: false),
                       collection: nil)
    # ######################################################################

    collection = FactoryGirl.create(:collection)
    2.times do
      FactoryGirl.create(:meta_datum_people,
                         people: [person_1],
                         meta_key: FactoryGirl.create(
                           :meta_key,
                           meta_datum_object_type: 'MetaDatum::People',
                           allowed_people_subtypes: ['Person'],
                           id: "test:#{Faker::Lorem.characters(8)}"
                         ),
                         media_entry: nil,
                         collection: collection)
    end
    FactoryGirl.create(:meta_datum_people,
                       people: [person_1],
                       meta_key: FactoryGirl.create(
                         :meta_key,
                         meta_datum_object_type: 'MetaDatum::People',
                         allowed_people_subtypes: ['Person'],
                         id: "test:#{Faker::Lorem.characters(8)}"
                       ),
                       media_entry: nil,
                       collection: FactoryGirl.create(:collection))

    expect(find_person(person_1_first_name)).to eq \
      Hash[:meta_data_usage_count, 6,
           :media_entries_usage_count, 2,
           :collections_usage_count, 2]

    expect(find_person(person_2_first_name)).to eq \
      Hash[:meta_data_usage_count, 0,
           :media_entries_usage_count, 0,
           :collections_usage_count, 0]

  end

  describe '#reject_blank_uris' do
    let(:person) { build :person }
    let(:url_1) { Faker::Internet.url }
    let(:url_2) { Faker::Internet.url }

    it 'does not persist blank uris' do
      person.external_uris = [
        url_1,
        '',
        url_2,
        ' '
      ]

      expect(person).to receive(:reject_blank_uris).and_call_original
      person.save!

      expect(person.external_uris).to eq([url_1, url_2])
    end
  end

  def find_person(first_name)
    Person
      .admin_with_usage_count
      .where(first_name: first_name)
      .first
      .as_json
      .symbolize_keys
      .slice(:meta_data_usage_count,
             :media_entries_usage_count,
             :collections_usage_count)
  end

end
