FactoryBot.define do

  factory :io_mapping do
    io_interface { IoInterface.first || create(:io_interface) }
    key_map { Faker::Lorem.word }
    meta_key
  end

end
