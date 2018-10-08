FactoryGirl.define do

  factory :role do
    label { Faker::Name.title }
    association :meta_key, factory: :meta_key_roles
  end

end
