FactoryGirl.define do

  factory :app_setting do
    context_for_show_summary 'core'
    contexts_for_validation ['core']
  end

end
