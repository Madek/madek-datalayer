class RefactorNotificationTables < ActiveRecord::Migration[6.1]
  include Madek::MigrationHelper

  def up
    [:ui, :ui_vars,
     :email_single, :email_single_vars,
     :email_single_subject, :email_single_subject_vars,
     :email_summary, :email_summary_vars,
     :email_summary_subject, :email_summary_subject_vars].each do |c|
       remove_column(:notification_templates, c)
     end

    rename_table(:notification_templates, :notification_cases)

    drop_table(:notification_templates_users_settings)

    create_table(:notification_cases_users_settings, id: :uuid) do |t|
      t.uuid(:user_id, null: false)
      t.string(:notification_case_label, null: false)
      t.string(:email_frequency, null: false, default: 'daily')
    end
    add_auto_timestamps :notification_cases_users_settings, null: false
    add_foreign_key(:notification_cases_users_settings, :notification_cases,
                    column: :notification_case_label, primary_key: :label,
                    name: "notification_cases_settings_tmpl_label_fk",
                    on_delete: :cascade)
    add_foreign_key(:notification_cases_users_settings, :users,
                    name: "notification_cases_settings_user_id_fk",
                    on_delete: :cascade)

    execute <<-SQL
      ALTER TABLE notification_cases_users_settings
      ADD CONSTRAINT check_email_regularity_value
      CHECK ( email_frequency IN ('immediately', 'daily', 'weekly', 'never') );
    SQL

  end
end
