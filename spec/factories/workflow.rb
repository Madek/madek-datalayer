FactoryGirl.define do

  factory :workflow do
    user { create(:user) }
    name { Faker::Educator.course }

    after(:create) do |workflow|
      create_list(:collection, 1, workflow: workflow)
    end
  end

end
