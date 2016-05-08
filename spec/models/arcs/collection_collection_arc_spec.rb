require 'spec_helper'
require 'spec_helper_no_tx'

describe Arcs::CollectionCollectionArc do

  context 'collection may not be its own parent' do
    it 'append to parent' do

      prepare_data

      check_counts(0, 0)

      # append child to parent => ok
      @parent.collections << @child

      check_counts(1, 1)

      # append parent to parent => raise trigger
      expect do
        @parent.collections << @parent
      end.to raise_error(/function collection_may_not_be_its_own_parent/i)

      check_counts(1, 1)

    end
  end

  private

  def check_counts(parent_count, child_count)
    @parent = Collection.find(@parent.id)
    @child = Collection.find(@child.id)
    expect(@parent.collections.length).to eq(parent_count)
    expect(@child.parent_collections.length).to eq(child_count)
  end

  def prepare_data
    prepare_madek_core

    @user = FactoryGirl.create :user

    @parent = create_collection('Parent')
    @child = create_collection('Child')
  end

  def prepare_madek_core
    if meta_key_title
      raise 'madek_core:title should not exist'
    end
    with_disabled_triggers do
      FactoryGirl.create(:meta_key_core_title)
    end
  end

  def create_collection(title)
    collection = FactoryGirl.create(:collection,
                                    get_metadata_and_previews: true,
                                    responsible_user: @user,
                                    creator: @user)
    MetaDatum::Text.create!(
      collection: collection,
      string: title,
      meta_key: meta_key_title,
      created_by: @user)
    collection
  end

  def meta_key_title
    MetaKey.find_by(id: 'madek_core:title')
  end

end
