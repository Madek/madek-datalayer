FactoryGirl.define do

  factory :collection do
    before(:create) do |collection|
      # we need app_setting for required context keys validation
      AppSetting.first.presence || create(:app_setting)

      collection.responsible_user_id ||= \
        (User.find_random || FactoryGirl.create(:user)).id
      collection.creator_id ||= (User.find_random || FactoryGirl.create(:user)).id
    end

    created_at { Time.now }
  end

  factory :collection_with_title, class: 'Collection' do
    # raise "not implemented yet"
  end

end
