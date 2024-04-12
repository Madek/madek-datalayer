class NotificationCaseUserSetting < ApplicationRecord
  self.table_name = 'notification_cases_users_settings'
  belongs_to(:user)
  belongs_to(:notification_case, foreign_key: :notification_case_label)
end
