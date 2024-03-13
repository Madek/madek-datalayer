FactoryBot.define do

  factory :notification do
    user
    notification_template
    data do
      NotificationTemplate.vars_stub(notification_template.ui_vars,
                                     random_vals: true)
    end

    trait(:with_email) do
      email
    end
  end

end
