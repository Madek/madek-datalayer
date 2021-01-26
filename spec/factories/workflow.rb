FactoryGirl.define do

  factory :workflow do
    creator { create(:user) }
    name { Faker::Educator.course }

    after(:create) do |workflow|
      create_list(
        :collection_with_title,
        1,
        workflow: workflow,
        is_master: true,
        title: workflow.name
      )
    end

    factory :finished_workflow do
      is_active false
    end
  end

end
