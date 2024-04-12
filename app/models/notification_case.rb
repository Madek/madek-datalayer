class NotificationCase < ApplicationRecord

  EMAIL_TEMPLATES = {
    transfer_responsibility: EmailTemplates::TransferResponsibility
  }.with_indifferent_access

  has_many(:users_settings,
           class_name: 'NotificationCaseUserSetting',
           foreign_key: :notification_case_label)

end
