FactoryBot.define do

  factory :notification do
    user
    notification_case { NotificationCase.all.sample }
    data { {} }
    # via_delegation { create(:delegation) }

    trait(:transfer_responsibility) do
      notification_case { NotificationCase.find_by(label: 'transfer_responsibility') }
    end

    trait(:with_email) do
      email
    end
  end

end
