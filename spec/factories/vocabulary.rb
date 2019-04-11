FactoryGirl.define do

  factory :vocabulary do
    id { Array.new(5) { Faker::Hacker.abbreviation }.join('-').downcase }
    label { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    admin_comment { Faker::Lorem.sentence }
  end

end
