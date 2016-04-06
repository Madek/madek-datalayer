require 'spec_helper'

describe AppSetting do

  describe '#uses_context_as' do
    let(:context) { create :context }
    let(:app_setting) { AppSetting.first.presence || create(:app_setting) }
    before do
      app_setting.update(
        { context_for_show_summary: context.id }.tap do |hash|
          %i(
            contexts_for_show_extra
            contexts_for_list_details
            contexts_for_validation
            contexts_for_dynamic_filters
          ).each do |attr|
            hash[attr] = [context.id]
          end
        end
      )
    end

    it 'returns an array with columns which include a given context ID' do
      expect(
        app_setting.uses_context_as(context.id)
      ).to eq %w(
        context_for_show_summary
        contexts_for_show_extra
        contexts_for_list_details
        contexts_for_validation
        contexts_for_dynamic_filters
      )
    end
  end

end
