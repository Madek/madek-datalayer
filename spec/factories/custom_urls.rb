FactoryGirl.define do

  factory :custom_url do
    id { Faker::Lorem.word }
    is_primary false

    updator { create(:user) }
    creator { create(:user) }
  end
end
