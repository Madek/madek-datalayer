FactoryBot.define do

  factory :role do
    labels do
      { AppSetting.default_locale => Faker::Lorem.characters(number: 10) }
    end
    association :creator, factory: :user
  end

end
