FactoryGirl.define do

  factory :vocabulary do
    id { Array.new(5) { Faker::Hacker.abbreviation }.join('-').downcase }
    labels do
      { AppSetting.default_locale => Faker::Lorem.word }
    end
    descriptions do
      { AppSetting.default_locale => Faker::Lorem.sentence }
    end
    admin_comment { Faker::Lorem.sentence }
  end

end
