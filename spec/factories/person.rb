FactoryGirl.define do

  factory :person do
    last_name { Faker::Name.last_name }
    first_name { Faker::Name.first_name }
    pseudonym { Faker::Lorem.word }
    searchable { "#{first_name} - #{pseudonym} - #{last_name}" }
    subtype 'Person'
  end

  factory :people_group, class: Person do
    last_name { Faker::Commerce.department }
    searchable { last_name }
    subtype 'PeopleGroup'
  end

  factory :people_instgroup, class: Person do
    last_name { Faker::Educator.course }
    searchable { last_name }
    subtype 'PeopleInstitutionalGroup'
  end

end
