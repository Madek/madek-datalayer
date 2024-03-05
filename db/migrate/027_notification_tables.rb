class NotificationTables < ActiveRecord::Migration[6.1]
  include Madek::MigrationHelper

  class MigrationGroup < ActiveRecord::Base
    self.table_name = 'groups'
    self.inheritance_column = nil
  end

  def up
    ##############################################################################################

    create_table(:notifications, id: :uuid) do |t|
      t.uuid(:user_id, null: false)
      t.text(:content, null: false)
      t.boolean(:acknowledged, null: false, default: false)
      t.string(:email_frequency, null: false, default: 'daily')
      t.uuid(:email_id, null: true)
    end
    add_auto_timestamps :notifications, null: false
    add_foreign_key(:notifications, :users, name: "notifications_user_id_fk", on_delete: :cascade)
    add_foreign_key(:notifications, :emails, name: "notifications_email_id_fk")

    # |-------------+-----------------|
    # | frequency   | email_id        |
    # |-------------|-----------------|
    # | immediately | NOT NULL        |
    # | daily       | NULL / NOT NULL |
    # | weekly      | NULL / NOT NULL |
    # | never       | NULL            |
    # |-------------+-----------------|
    execute <<-SQL
      ALTER TABLE notifications
      ADD CONSTRAINT check_notifications_email_frequency_and_email_id
      CHECK (
        ( email_frequency = 'immediately' AND email_id IS NOT NULL ) OR
        ( email_frequency IN ('daily', 'weekly') AND ( email_id IS NULL OR email_id IS NOT NULL ) ) OR
        ( email_frequency = 'never' AND email_id IS NULL )
      );
    SQL

    execute <<-SQL
      CREATE OR REPLACE FUNCTION delete_old_notifications_f()
      RETURNS TRIGGER AS $$
      BEGIN
        DELETE FROM notifications WHERE created_at < CURRENT_DATE - INTERVAL '180 days';
        RETURN NEW;
      END;
      $$ language 'plpgsql';
    SQL

    execute <<-SQL
      CREATE CONSTRAINT TRIGGER delete_old_notifications_t
      AFTER INSERT OR UPDATE
      ON notifications
      FOR EACH ROW
      EXECUTE PROCEDURE delete_old_notifications_f()
    SQL

    ##############################################################################################

    create_table(:notification_templates, id: false) do |t|
      t.string(:label, null: false)
      t.text(:description)
      t.text(:ui_en, null: false)
      t.text(:ui_de, null: false)
      t.text(:email_single_en, null: false)
      t.text(:email_single_de, null: false)
      t.text(:email_summary_en, null: false)
      t.text(:email_summary_de, null: false)
    end
    add_auto_timestamps :notification_templates, null: false
    execute <<-SQL
      ALTER TABLE ONLY notification_templates
      ADD CONSTRAINT notification_templates_pkey PRIMARY KEY (label);
    SQL

    ##############################################################################################

    create_table(:notification_templates_users_settings, id: :uuid) do |t|
      t.uuid(:user_id, null: false)
      t.string(:notification_template_label, null: false)
      t.string(:email_frequency, null: false, default: 'daily')
    end
    add_auto_timestamps :notification_templates_users_settings, null: false
    add_foreign_key(:notification_templates_users_settings, :notification_templates,
                    column: :notification_template_label, primary_key: :label,
                    name: "notification_templates_settings_tmpl_label_fk",
                    on_delete: :cascade)
    add_foreign_key(:notification_templates_users_settings, :users,
                    name: "notification_templates_settings_user_id_fk",
                    on_delete: :cascade)

    execute <<-SQL
      ALTER TABLE notification_templates_users_settings
      ADD CONSTRAINT check_email_regularity_value
      CHECK ( email_frequency IN ('immediately', 'daily', 'weekly', 'never') );
    SQL

    MigrationGroup.create!(id: Madek::Constants::BETA_TESTERS_NOTIFICATIONS_GROUP_ID.to_s,
                           name: "Beta-Tester \"Notifications\"")
  end

  def down
    execute 'DROP TRIGGER delete_old_notifications_t ON notifications CASCADE'
    drop_table(:notification_templates_users_settings)
    drop_table(:notification_templates)
    drop_table(:notifications)
  end
end
