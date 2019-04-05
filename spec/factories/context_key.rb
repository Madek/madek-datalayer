FactoryGirl.define do

  factory :context_key do
    context { create(:context) }
    meta_key { MetaKey.first || create(:meta_key_text) }
    id { Faker::Internet.slug(nil, '-') }
    labels do
      { AppSetting.default_locale => Faker::Lorem.word }
    end
    descriptions do
      { AppSetting.default_locale => Faker::Lorem.sentence }
    end
    hints do
      { AppSetting.default_locale => Faker::Lorem.sentence }
    end
    admin_comment { Faker::Lorem.sentence }
    sequence(:position) { |n| n }
    is_required false
    length_min 16
    length_max 128
  end

end
