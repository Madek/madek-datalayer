require 'spec_helper'

describe Workflow do
  describe '#part_of_workflow?' do
    it 'checks if media entry is part of workflow' do
      workflow = create :workflow
      master_collection = workflow.collections.first
      collection_1 = create :collection
      collection_2 = create :collection
      collection_3 = create :collection
      media_entry = create :media_entry_with_title
      media_entry_2 = create :media_entry_with_title
      master_collection.collections << collection_1
      collection_1.collections << collection_2
      collection_2.collections << collection_3
      collection_3.media_entries << media_entry

      # result = MediaEntry.connection.exec_query MediaEntry.parent_ids_query(media_entry)
      # row = result.rows.last

      # binding.pry

      expect(media_entry.part_of_workflow?).to be true
      expect(media_entry_2.part_of_workflow?).to be false
    end
  end
end
