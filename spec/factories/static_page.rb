FactoryBot.define do

  factory :static_page do
    name { Faker::Lorem.characters(number: 10) }
    contents do
      { AppSetting.default_locale => Faker::Lorem.paragraph }
    end
  end

end
