FactoryGirl.define do

  factory :role do
    labels do
      { AppSetting.default_locale => Faker::Name.title }
    end
    association :creator, factory: :user
    meta_key do
      MetaKey.find_by(id: attributes_for(:meta_key_roles)[:id]) ||
        create(:meta_key_roles)
    end
  end

end
