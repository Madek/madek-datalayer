RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_can_be, 'it can be'
end

RSpec.shared_examples 'part of workflow' do
  before(:all) do
    @workflow = create :workflow

    @master_collection = @workflow.collections.first
    @media_entry = create :media_entry_with_title
    @master_collection.media_entries << @media_entry

    @collection_1 = create :collection
    @collection_2 = create :collection
    @collection_3 = create :collection
    @nested_media_entry = create :media_entry_with_title
    @master_collection.collections << @collection_1
    @collection_1.collections << @collection_2
    @collection_2.collections << @collection_3
    @collection_3.media_entries << @nested_media_entry

    @standalone_media_entry = create :media_entry_with_title
    @standalone_collection = create :collection
    @standalone_collection.media_entries << @standalone_media_entry
  end

  describe '#part_of_workflow?' do
    it 'checks if media entry is part of any workflow' do
      case subject
      when MediaEntry
        expect(@media_entry.part_of_workflow?).to be true
        expect(@nested_media_entry.part_of_workflow?).to be true
        expect(@standalone_media_entry.part_of_workflow?).to be false
      when Collection
        expect(@master_collection.part_of_workflow?).to be true
        expect(@collection_1.part_of_workflow?).to be true
        expect(@collection_2.part_of_workflow?).to be true
        expect(@collection_3.part_of_workflow?).to be true
        expect(@standalone_collection.part_of_workflow?).to be false
      end
    end
  end

  describe '#workflow' do
    it "returns the workflow #{described_class} is part of" do
      case subject
      when MediaEntry
        expect(@media_entry.workflow).to eq(@workflow)
        expect(@nested_media_entry.workflow).to eq(@workflow)
      when Collection
        expect(@master_collection.workflow).to eq(@workflow)
        expect(@collection_1.workflow).to eq(@workflow)
        expect(@collection_2.workflow).to eq(@workflow)
        expect(@collection_3.workflow).to eq(@workflow)
      end
    end

    it "returns nil if #{described_class} isn't part of any workflow" do
      case subject
      when MediaEntry
        expect(@standalone_media_entry.workflow).to be_nil
      when Collection
        expect(@standalone_collection.workflow).to be_nil
      end
    end
  end
end
