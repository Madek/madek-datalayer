class NotificationTemplateUserSetting < ApplicationRecord
  self.table_name = 'notification_templates_users_settings'
  belongs_to(:user)
  belongs_to(:notification_template, foreign_key: :notification_template_label)
end
