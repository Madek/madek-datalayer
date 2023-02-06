FactoryBot.define do

  factory :custom_url do
    id { Faker::Lorem.sentence.parameterize } # NOTE: must adhere to constraints!
    is_primary { false }

    updator { create(:user) }
    creator { create(:user) }
  end
end
