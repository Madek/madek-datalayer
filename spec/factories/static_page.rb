FactoryGirl.define do

  factory :static_page do
    name { Faker::Name.title }
    contents do
      { AppSetting.default_locale => Faker::Lorem.paragraph }
    end
  end

end
