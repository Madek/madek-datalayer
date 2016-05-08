FactoryGirl.define do

  factory :filter_set do
    created_at { Time.now }

    association :responsible_user, factory: :user
    association :creator, factory: :user

    before :create do |md|
      # we need app_setting for required context keys validation
      AppSetting.first.presence || create(:app_setting)
    end

  end

end
