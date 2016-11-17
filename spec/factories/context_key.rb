FactoryGirl.define do

  factory :context_key do
    context { create(:context) }
    meta_key { MetaKey.first || create(:meta_key_text) }
    id { Faker::Internet.slug(nil, '-') }
    label { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    hint { Faker::Lorem.sentence }
    admin_comment { Faker::Lorem.sentence }
    sequence(:position) { |n| n }
    is_required false
    length_min 16
    length_max 128
  end

end
