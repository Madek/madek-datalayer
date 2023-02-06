require 'spec_helper'
require_relative 'shared/previous_ids'

describe Person do

  it 'usage count in meta data' do

    person_1_first_name = Faker::Lorem.characters(number: 8)
    person_1 = FactoryBot.create(:person, first_name: person_1_first_name)

    person_2_first_name = Faker::Lorem.characters(number: 8)
    FactoryBot.create(:person, first_name: person_2_first_name)

    media_entry = FactoryBot.create(:media_entry)
    2.times do
      FactoryBot.create(:meta_datum_people,
                         people: [person_1],
                         meta_key: FactoryBot.create(
                           :meta_key,
                           meta_datum_object_type: 'MetaDatum::People',
                           allowed_people_subtypes: ['Person'],
                           id: "test:#{Faker::Lorem.characters(number: 8)}"
                         ),
                         media_entry: media_entry,
                         collection: nil)
    end
    FactoryBot.create(:meta_datum_people,
                       people: [person_1],
                       meta_key: FactoryBot.create(
                         :meta_key,
                         meta_datum_object_type: 'MetaDatum::People',
                         allowed_people_subtypes: ['Person'],
                         id: "test:#{Faker::Lorem.characters(number: 8)}"
                       ),
                       media_entry: FactoryBot.create(:media_entry),
                       collection: nil)
    # ######################################################################
    # unpublished entry
    FactoryBot.create(:meta_datum_people,
                       people: [person_1],
                       meta_key: FactoryBot.create(
                         :meta_key,
                         meta_datum_object_type: 'MetaDatum::People',
                         allowed_people_subtypes: ['Person'],
                         id: "test:#{Faker::Lorem.characters(number: 8)}"
                       ),
                       media_entry: FactoryBot.create(:media_entry,
                                                       is_published: false),
                       collection: nil)
    # ######################################################################

    collection = FactoryBot.create(:collection)
    2.times do
      FactoryBot.create(:meta_datum_people,
                         people: [person_1],
                         meta_key: FactoryBot.create(
                           :meta_key,
                           meta_datum_object_type: 'MetaDatum::People',
                           allowed_people_subtypes: ['Person'],
                           id: "test:#{Faker::Lorem.characters(number: 8)}"
                         ),
                         media_entry: nil,
                         collection: collection)
    end
    FactoryBot.create(:meta_datum_people,
                       people: [person_1],
                       meta_key: FactoryBot.create(
                         :meta_key,
                         meta_datum_object_type: 'MetaDatum::People',
                         allowed_people_subtypes: ['Person'],
                         id: "test:#{Faker::Lorem.characters(number: 8)}"
                       ),
                       media_entry: nil,
                       collection: FactoryBot.create(:collection))

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

  describe '#merge_to' do
    let(:person) { create(:person) }
    let(:receiver) { create(:person) }

    it 'deletes person' do
      expect(person).to receive(:destroy!)

      person.merge_to(receiver, nil)
    end

    it 'remembers previous id' do
      expect { person.merge_to(receiver, nil) }.to change {
        PreviousIds::PreviousPersonId
          .where(previous_id: person.id, person_id: receiver.id)
          .count
      }.by(1)
    end
  end

  include_examples 'previous ids'

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
