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
  'validates.rb',
  'part_of_workflow.rb'
].each do |file|
  require Rails.root.join 'spec', 'models', 'shared', file
end

##########################################################

describe MediaEntry do

  context 'Creation' do

    it 'should be producible by a factory' do
      expect { FactoryGirl.create :media_entry }.not_to raise_error
    end

  end

  describe 'Update' do

    it_validates 'presence of', :responsible_user_id
    it_validates 'presence of', :creator_id

  end

  context 'an existing MediaEntry' do

    it_behaves_like 'a favoritable' do
      let(:resource) { FactoryGirl.create :media_entry }
    end

    it_has 'edit sessions' do
      let(:resource_type) { :media_entry }
    end

  end

  it_provides_scope 'created by user'
  it_provides_scope 'entrusted to user'
  it_provides_scope 'favored by user'
  it_provides_scope 'in responsibility of user'

  context 'reader methods for meta_data' do

    it_provides_reader_method_for 'title'
    it_provides_reader_method_for 'description'
    it_provides_reader_method_for 'keywords'

  end

  it_responds_to 'permission_types_for_user' do
    let(:irrelevant_group_perm_types) { [:edit_permissions] }
  end

  it 'can not be published if required meta data is missing' do
    media_entry = FactoryGirl.create(:media_entry, is_published: false)

    validation_context_id = 'upload'
    Context.find_by_id(validation_context_id) \
      or FactoryGirl.create(:context, id: validation_context_id)
    AppSetting.first.update_attributes! \
      contexts_for_entry_validation: [validation_context_id]
    FactoryGirl.create(:context_key,
                       context_id: validation_context_id,
                       is_required: true)

    expect(media_entry.update_attributes(is_published: true)).to be false
    media_entry.reload
    expect(media_entry.is_published?).to be false
  end

  it_can 'be found via custom id'
  it_can_be 'part of workflow'
end
