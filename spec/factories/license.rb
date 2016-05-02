FactoryGirl.define do

  factory :license do
    label { Faker::Lorem.words(3).join(' ') }
    url { Faker::Internet.url('example.com', "/licenses/#{SecureRandom.uuid}") }
  end

end
