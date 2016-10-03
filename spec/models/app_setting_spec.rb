require 'spec_helper'

describe AppSetting do
  let(:context) { create :context }
  let(:app_setting) { AppSetting.first.presence || create(:app_setting) }
  let(:random_uuid) { SecureRandom.uuid }
  before do
    app_setting.assign_attributes(
      {
        context_for_entry_summary: context.id,
        context_for_collection_summary: context.id
      }.tap do |hash|
        %i(
          contexts_for_entry_extra
          contexts_for_entry_edit
          contexts_for_collection_edit
          contexts_for_list_details
          contexts_for_validation
          contexts_for_dynamic_filters
        ).each do |attr|
          hash[attr] = [context.id]
        end
      end
    )
  end

  describe '#uses_context_as' do
    it 'returns an array with columns which include a given context ID' do
      expect(
        app_setting.uses_context_as(context.id).sort
      ).to eq %w(
        context_for_entry_summary
        context_for_collection_summary
        contexts_for_entry_extra
        contexts_for_entry_edit
        contexts_for_collection_edit
        contexts_for_list_details
        contexts_for_validation
        contexts_for_dynamic_filters
      ).sort
    end
  end

  describe 'custom context getters' do
    context 'when context values are missing' do
      before do
        app_setting.assign_attributes(
          attributes_for(:app_setting_without_contexts)
        )
      end

      it 'returns nil or empty arrays' do
        expect(app_setting.context_for_entry_summary).to be_nil
        expect(app_setting.context_for_collection_summary).to be_nil
        expect(app_setting.contexts_for_entry_extra).to eq []
        expect(app_setting.contexts_for_entry_edit).to eq []
        expect(app_setting.contexts_for_collection_edit).to eq []
        expect(app_setting.contexts_for_list_details).to eq []
        expect(app_setting.contexts_for_validation).to eq []
        expect(app_setting.contexts_for_dynamic_filters).to eq []
      end
    end

    context 'when context values are present' do
      it 'returns Context or array of Contexts' do
        expect(app_setting.context_for_entry_summary).to eq context
        expect(app_setting.context_for_collection_summary).to eq context
        expect(app_setting.contexts_for_entry_extra).to eq [context]
        expect(app_setting.contexts_for_list_details).to eq [context]
        expect(app_setting.contexts_for_validation).to eq [context]
        expect(app_setting.contexts_for_dynamic_filters).to eq [context]
      end
    end

    context 'when some of context values are invalid' do
      before do
        app_setting.assign_attributes(
          attributes_for(:app_setting_with_some_invalid_contexts)
        )
      end

      it 'returns only valid Contexts' do
        valid_context = Context.find_by(id: 'core') || \
                        create(:context, id: 'core')
        expect(app_setting.context_for_entry_summary).to be_nil
        expect(app_setting.context_for_collection_summary).to be_nil
        expect(app_setting.contexts_for_entry_extra).to eq [valid_context]
        expect(app_setting.contexts_for_list_details).to eq [valid_context]
        expect(app_setting.contexts_for_validation).to eq [valid_context]
        expect(app_setting.contexts_for_dynamic_filters).to eq [valid_context]
      end
    end
  end

  describe 'featured set id validation' do
    context 'when set with the id exists' do
      it 'is valid' do
        app_setting.featured_set_id = create(:collection).id
        expect(app_setting).to be_valid
      end
    end

    context 'when set with the id does not exist' do
      it 'is not valid' do
        app_setting.featured_set_id = random_uuid
        expect(app_setting).not_to be_valid
        expect(app_setting.errors.messages[:base]).to eq \
          ["The set with a given ID: #{random_uuid} doesn't exist!"]
      end
    end
  end

  it 'catalog context keys types validation' do
    meta_key_keywords = \
      FactoryGirl.create(:meta_key_keywords,
                         id: "test:#{Faker::Lorem.characters(8)}")
    context_key_keywords = \
      FactoryGirl.create(:context_key, meta_key: meta_key_keywords)

    meta_key_text = \
      FactoryGirl.create(:meta_key_text,
                         id: "test:#{Faker::Lorem.characters(8)}")
    context_key_text = \
      FactoryGirl.create(:context_key, meta_key: meta_key_text)

    meta_key_text_date = \
      FactoryGirl.create(:meta_key_text_date,
                         id: "test:#{Faker::Lorem.characters(8)}")
    context_key_text_date = \
      FactoryGirl.create(:context_key, meta_key: meta_key_text_date)

    meta_key_people = \
      FactoryGirl.create(:meta_key_people,
                         id: "test:#{Faker::Lorem.characters(8)}")
    context_key_people = \
    FactoryGirl.create(:context_key, meta_key: meta_key_people)

    app_setting.catalog_context_keys = [context_key_keywords.id,
                                        context_key_text.id,
                                        context_key_text_date.id,
                                        context_key_people.id]
    expect(app_setting).not_to be_valid
    expect(app_setting.errors.messages[:base]).to match_array \
      ["The meta_key for context_key #{context_key_text.id} " \
       "is not of type 'MetaDatum::Keywords'",
       "The meta_key for context_key #{context_key_text_date.id} " \
       "is not of type 'MetaDatum::Keywords'",
       "The meta_key for context_key #{context_key_people.id} " \
       "is not of type 'MetaDatum::Keywords'"]
  end

end
