RSpec.shared_examples 'previous ids' do
  let(:factory_name) { described_class.name.downcase }

  describe '#previous_ids' do
    context 'when there were merges' do
      it 'returns array of 3 previous ids' do
        resource_1 = create(factory_name)
        resource_2 = create(factory_name)
        resource_3 = create(factory_name)
        receiver = create(factory_name)

        resource_1.merge_to(receiver)
        resource_2.merge_to(receiver)
        resource_3.merge_to(receiver)

        expect(Set.new(receiver.previous_ids)).to \
          eq(Set.new([resource_2.id, resource_3.id, resource_1.id]))
      end
    end

    context 'when there was no merge' do
      it 'returns an empty array' do
        resource = create(factory_name)

        expect(resource.previous_ids).to eq([])
      end
    end
  end

  describe '.find_by_previous_id' do
    it 'finds a record with previous id' do
      resource_1 = create(factory_name)
      resource_2 = create(factory_name)
      receiver = create(factory_name)

      resource_1.merge_to(receiver)
      resource_2.merge_to(receiver)

      expect(
        described_class.find_by_previous_id(resource_2.id)
      ).to eq(receiver)
      expect(
        described_class.find_by_previous_id(resource_1.id)
      ).to eq(receiver)
    end
  end

  describe '#merge_to' do
    specify 'resource can be merged only once' do
      resource = create(factory_name)
      receiver_1 = create(factory_name)
      receiver_2 = create(factory_name)

      resource.merge_to(receiver_1)
      expect { resource.merge_to(receiver_2) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
