RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_can_be, 'it can be'
end

RSpec.shared_examples 'part of workflow' do
  describe '#part_of_workflow?' do
    it 'checks if media entry is part of workflow' do
      workflow = create :workflow
      master_collection = workflow.collections.first
      collection_1 = create :collection
      collection_2 = create :collection
      collection_3 = create :collection
      media_entry = create :media_entry_with_title
      master_collection.collections << collection_1
      collection_1.collections << collection_2
      collection_2.collections << collection_3
      collection_3.media_entries << media_entry

      standalone_media_entry = create :media_entry_with_title
      standalone_collection = create :collection
      standalone_collection.media_entries << standalone_media_entry

      expect(media_entry.part_of_workflow?).to be true
      expect(standalone_media_entry.part_of_workflow?).to be false
      expect(media_entry.workflow).to eq(workflow)
      expect(standalone_media_entry.workflow).to be_nil
    end
  end
end
