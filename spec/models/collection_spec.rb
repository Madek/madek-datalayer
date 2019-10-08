require 'spec_helper'

[
  'created_by_user.rb',
  'edit_sessions.rb',
  'entrusted_to_user.rb',
  'favored_by_user.rb',
  'favoritable.rb',
  'find_by_custom_id.rb',
  'in_responsibility_of_user.rb',
  'meta_data.rb',
  'permission_types_for_user.rb',
  'validates.rb'
]
  .each do |file|
  require Rails.root.join 'spec', 'models', 'shared', file
end

##########################################################

describe Collection do

  describe 'Creation' do

    it 'should be producible by a factory' do
      expect { FactoryGirl.create :collection }.not_to raise_error
    end

  end

  describe 'Update' do

    it_validates 'presence of', :responsible_user_id
    it_validates 'presence of', :creator_id

  end

  context 'an existing Collection' do

    it_behaves_like 'a favoritable' do
      let(:resource) { FactoryGirl.create :collection }
    end

    it_has 'edit sessions' do
      let(:resource_type) { :media_entry }
    end
  end

  it_provides_scope 'created by user'
  it_provides_scope 'entrusted to user'
  it_provides_scope 'favored by user'
  it_provides_scope 'in responsibility of user'

  context 'media_entries association' do

    before :example do
      @collection = FactoryGirl.create(:collection)
      @media_entry = FactoryGirl.create(:media_entry)
    end

    it 'highlights' do
      FactoryGirl.create \
        :collection_media_entry_arc,
        collection: @collection,
        media_entry: @media_entry,
        highlight: true

      child_coll = create(:collection)
      FactoryGirl.create \
        :collection_collection_arc,
        parent: @collection,
        child: child_coll,
        highlight: true

      filter_set = create(:filter_set)
      FactoryGirl.create \
        :collection_filter_set_arc,
        collection: @collection,
        filter_set: filter_set,
        highlight: true

      expect(@collection.highlighted_media_entries.count).to be == 1
      expect(@collection.highlighted_media_entries).to include @media_entry
      expect(@collection.highlighted_collections.count).to be == 1
      expect(@collection.highlighted_collections).to include child_coll
      expect(@collection.highlighted_filter_sets.count).to be == 1
      expect(@collection.highlighted_filter_sets).to include filter_set
    end

    it 'cover' do
      coll = create(:collection)
      me1 = create(:media_entry)
      me2 = create(:media_entry)
      coll.media_entries << me1
      coll.media_entries << me2

      coll.cover = me1
      coll.cover = me2
      expect(coll.cover).to be == me2
    end
  end

  it 'collections association' do
    @parent = FactoryGirl.create(:collection)
    @child = FactoryGirl.create(:collection)

    FactoryGirl.create \
      :collection_collection_arc,
      parent: @parent,
      child: @child

    expect(@parent.collections.count).to be == 1
    expect(@parent.collections).to include @child
  end

  it 'filter_sets association' do
    @collection = FactoryGirl.create(:collection)
    @filter_set = FactoryGirl.create(:filter_set)

    FactoryGirl.create \
      :collection_filter_set_arc,
      collection: @collection,
      filter_set: @filter_set

    expect(@collection.filter_sets.count).to be == 1
    expect(@collection.filter_sets).to include @filter_set
  end

  context 'reader methods for meta_data' do

    it_provides_reader_method_for 'title'
    it_provides_reader_method_for 'description'
    it_provides_reader_method_for 'keywords'

  end

  it_responds_to 'permission_types_for_user' do
    let(:irrelevant_group_perm_types) { [:edit_permissions] }
  end

  it_can 'be found via custom id'

  describe '.not_part_of_finished_workflow' do
    let(:active_workflow) { create :workflow }
    let(:finished_workflow) { create :finished_workflow }

    context 'when collection belongs to active workflow' do
      it 'return the collection' do
        collection = active_workflow.master_collection

        expect(Collection.not_part_of_finished_workflow).to include collection
      end
    end

    context 'when collection belongs to finished workflow' do
      it 'does not return the collection' do
        collection = finished_workflow.master_collection

        expect(Collection.not_part_of_finished_workflow).not_to include collection
      end
    end

    context 'when collection does not belongs to any workflow' do
      it 'returns the collection' do
        collection = create :collection

        expect(Collection.not_part_of_finished_workflow).to include collection
      end
    end
  end
end
