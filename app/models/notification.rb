class Notification < ApplicationRecord
  include Concerns::Notifications::PeriodicEmails
  include Concerns::Notifications::TransferResponsibility

  belongs_to(:user)
  belongs_to(:via_delegation, foreign_key: :via_delegation_id,
             class_name: 'Delegation', optional: true)
  belongs_to(:email, optional: true)
  belongs_to(:notification_case, foreign_key: :notification_case_label)

  scope :acknowledged, -> { where(acknowledged: true) }
  scope :with_user_settings, -> {
    joins(:notification_case)
      .joins(<<~SQL)
        LEFT JOIN notification_cases_users_settings ntus
          ON notification_cases.label = ntus.notification_case_label
          AND notifications.user_id = ntus.user_id
      SQL
  }

  def data
    read_attribute(:data).with_indifferent_access
  end

  def user_settings
    notification_case.users_settings.where(user_id: self.id)
  end
end
