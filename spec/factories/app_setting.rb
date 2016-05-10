FactoryGirl.define do

  factory :app_setting do
    context_for_show_summary 'core'
    contexts_for_show_extra ['core']
  end

  factory :app_setting_without_contexts, class: AppSetting do
    context_for_show_summary ''
    contexts_for_show_extra []
    contexts_for_list_details []
    contexts_for_validation []
    contexts_for_dynamic_filters []
  end

  factory :app_setting_with_some_invalid_contexts, class: AppSetting do
    context_for_show_summary 'foo'
    contexts_for_show_extra %w(foo core)
    contexts_for_list_details %w(core foo)
    contexts_for_validation %w(foo core)
    contexts_for_dynamic_filters %w(core foo)
  end
end
