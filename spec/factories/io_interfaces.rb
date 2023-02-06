FactoryBot.define do

  factory :io_interface do
    id { Faker::Lorem.characters(number: 10) }
  end

end
