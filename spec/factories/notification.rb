FactoryBot.define do

  factory :notification do
    user
    association :notification_case
    data { {} }
    # via_delegation { create(:delegation) }

    trait(:transfer_responsibility) do
      notification_case do
        NotificationCase.find_or_create_by!(label: 'transfer_responsibility') do |notification_case|
          notification_case.description = 'Transfer responsibility notification'
        end
      end
    end

    trait(:with_email) do
      email
    end
  end

end
