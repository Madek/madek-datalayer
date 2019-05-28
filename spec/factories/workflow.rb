FactoryGirl.define do

  factory :workflow do
    creator { create(:user) }
    name { Faker::Educator.course }

    after(:create) do |workflow|
      create_list(:collection, 1, workflow: workflow, is_master: true)
    end

    factory :finished_workflow do
      is_active false
    end
  end

end
