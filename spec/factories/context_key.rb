FactoryBot.define do

  factory :context_key do
    context { create(:context) }
    meta_key { MetaKey.first || create(:meta_key_text) }
    sequence(:id) { |n| "#{Faker::Internet.slug(words: nil, glue: '-')}-#{n}" }
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
    is_required { false }
    length_min { 16 }
    length_max { 128 }
  end

end
