class NotificationCase < ApplicationRecord

  has_many(:users_settings,
           class_name: 'NotificationCaseUserSetting',
           foreign_key: :notification_case_label)

end
