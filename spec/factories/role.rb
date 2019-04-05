FactoryGirl.define do

  factory :role do
    labels do
      { AppSetting.default_locale => Faker::Name.title }
    end
    association :creator, factory: :user
    association :meta_key, factory: :meta_key_roles
  end

end
