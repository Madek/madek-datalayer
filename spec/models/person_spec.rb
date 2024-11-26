require 'spec_helper'
require_relative 'shared/previous_ids'

describe Person do

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

end
