FactoryBot.define do

  factory :person do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    pseudonym { Faker::Artist.name }
    subtype { 'Person' }
  end

  factory :people_group, class: Person do
    last_name { Faker::Commerce.department }
    subtype { 'PeopleGroup' }
  end

  factory :people_instgroup, class: Person do
    last_name { Faker::Educator.course }
    subtype { 'PeopleInstitutionalGroup' }
  end

end
