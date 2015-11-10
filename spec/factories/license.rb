FactoryGirl.define do

  factory :license do
    label { Faker::Lorem.words(3).join(' ') }
  end

end
