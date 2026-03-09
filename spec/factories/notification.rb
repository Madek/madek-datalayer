FactoryBot.define do

  factory :notification do
    user
    notification_case { NotificationCase.all.sample }
    data { {} }
    # via_delegation { create(:delegation) }

    trait(:transfer_responsibility) do
      notification_case do
        NotificationCase.find_or_create_by!(label: 'transfer_responsibility') do |notification_case|
          notification_case.description = 'Transfer responsibility notification'
          notification_case.allowed_email_frequencies = %w[never daily weekly]
        end
      end
    end

    trait(:with_email) do
      email
    end
  end

end
