FactoryGirl.define do

  factory :delegation do |n|
    name { Faker::Lorem.words(7).join(' ') }
    description { Faker::Lorem.paragraph }
    admin_comment { Faker::Lorem.sentence }
  end

end
