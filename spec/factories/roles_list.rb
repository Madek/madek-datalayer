FactoryBot.define do

  factory :roles_list do
    labels do
      { AppSetting.default_locale => Faker::Lorem.characters(number: 10) }
    end
  end

end
