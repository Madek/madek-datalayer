FactoryGirl.define do

  factory :app_setting do
    context_for_entry_summary 'core'
    contexts_for_entry_extra ['core']
  end

  factory :app_setting_without_contexts, class: AppSetting do
    context_for_entry_summary ''
    context_for_collection_summary ''
    contexts_for_entry_extra []
    contexts_for_resource_edit []
    contexts_for_list_details []
    contexts_for_validation []
    contexts_for_dynamic_filters []
  end

  factory :app_setting_with_some_invalid_contexts, class: AppSetting do
    context_for_entry_summary 'foo'
    context_for_collection_summary 'foo'
    contexts_for_entry_extra %w(foo core)
    contexts_for_resource_edit %w(foo core)
    contexts_for_list_details %w(core foo)
    contexts_for_validation %w(foo core)
    contexts_for_dynamic_filters %w(core foo)
  end
end
