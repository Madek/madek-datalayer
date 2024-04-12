FactoryBot.define do

  factory :notification do
    user
    notification_case
    data { {} }

    trait(:with_email) do
      email
    end
  end

end
