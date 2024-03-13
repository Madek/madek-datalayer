class Notification < ApplicationRecord
  include Concerns::Notifications::Emails
  include Concerns::Notifications::TransferResponsibility

  belongs_to(:user)
  belongs_to(:email, optional: true)
  belongs_to(:notification_template, foreign_key: :notification_template_label)

  scope :acknowledged, -> { where(acknowledged: true) }
  scope :with_user_settings, -> {
    joins(:notification_template)
      .joins(<<~SQL)
        LEFT JOIN notification_templates_users_settings ntus
          ON notification_templates.label = ntus.notification_template_label
          AND notifications.user_id = ntus.user_id
      SQL
  }

  def data
    read_attribute(:data).with_indifferent_access
  end

  def user_settings
    notification_template.users_settings.where(user_id: self.id)
  end
end
