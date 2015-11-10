FactoryGirl.define do

  factory :person do
    last_name { Faker::Name.last_name }
    first_name { Faker::Name.first_name }
    pseudonym { Faker::Lorem.word }
    searchable { "#{first_name} - #{pseudonym} - #{last_name}" }
  end

end
