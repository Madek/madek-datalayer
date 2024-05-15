class UniqueIndexNotifCasesUsersSettings < ActiveRecord::Migration[6.1]
  include Madek::MigrationHelper

  def change
    add_index(:notification_cases_users_settings, [:notification_case_label, :user_id],
              name: 'index_notif_case_label_user_id',
              unique: true)
  end
end
