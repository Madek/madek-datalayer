class Notifications < ActiveRecord::Migration[6.1]
  include Madek::MigrationHelper

  def up
    create_table(:notifications, id: :uuid) do |t|
      t.uuid(:user_id, null: false)
      t.boolean(:is_acknowledged, null: false, default: false)
      t.boolean(:is_delivered_via_email, null: false, default: false)
      t.boolean(:is_delivered_via_ui, null: false, default: false)
      t.text(:content, null: false)
      t.uuid(:email_id, null: true)
    end
    add_auto_timestamps :notifications
    add_foreign_key(:notifications, :users, name: "notifications_user_id_fk", on_delete: :cascade)
    add_foreign_key(:notifications, :emails, name: "notifications_email_id_fk")

    # | ui | email | ack |
    # | n  | n     | n   |
    # | y  | n     | n   |
    # | y  | y     | n   |
    # | n  | y     | n   |
    # | y  | n     | n   |
    # | y  | y     | y   |
    #
    # NOTE: `is_acknowledged` is meant only for `is_delivered_via_ui`.
    execute <<-SQL
      ALTER TABLE notifications
      ADD CONSTRAINT check_delivery_types_with_is_acknowledged
      CHECK (
        ( NOT is_delivered_via_ui AND NOT is_delivered_via_email AND NOT is_acknowledged ) OR
        ( is_delivered_via_ui AND NOT is_delivered_via_email AND NOT is_acknowledged ) OR
        ( is_delivered_via_ui AND is_delivered_via_email AND NOT is_acknowledged ) OR
        ( NOT is_delivered_via_ui AND is_delivered_via_email AND NOT is_acknowledged ) OR
        ( is_delivered_via_ui AND NOT is_delivered_via_email AND is_acknowledged ) OR
        ( is_delivered_via_ui AND is_delivered_via_email AND is_acknowledged )
      )
    SQL

    execute <<-SQL
      ALTER TABLE notifications
      ADD CONSTRAINT check_is_delivered_via_email_and_email_id
      CHECK (
        ( is_delivered_via_email AND email_id IS NOT NULL ) OR
        ( NOT is_delivered_via_email AND email_id IS NULL )
      )
    SQL

    execute <<-SQL
      CREATE OR REPLACE FUNCTION delete_old_notifications_f()
      RETURNS TRIGGER AS $$
      BEGIN
        DELETE FROM emails WHERE created_at < CURRENT_DATE - INTERVAL '90 days';
        RETURN NEW;
      END;
      $$ language 'plpgsql';
    SQL

    execute <<-SQL
      CREATE CONSTRAINT TRIGGER delete_old_notifications_t
      AFTER INSERT OR UPDATE
      ON emails
      FOR EACH ROW
      EXECUTE PROCEDURE delete_old_notifications_f()
    SQL

    create_table(:notifications_settings, id: :uuid) do |t|
      t.uuid(:user_id, null: false)
      t.boolean(:deliver_via_email, null: false, default: false)
      t.boolean(:deliver_via_ui, null: false, default: false)
      t.string(:deliver_via_email_regularity, null: false, default: 'immediately')
    end
    add_auto_timestamps :notifications_settings
    add_foreign_key(:notifications_settings, :users, name: "notifications_settings_user_id_fk", on_delete: :cascade)

    execute <<-SQL
      ALTER TABLE notifications_settings
      ADD CONSTRAINT check_email_regularity_value
      CHECK ( deliver_via_email_regularity IN ('immediately', 'daily', 'weekly') );
    SQL

  end

  def down
    drop_table(:notifications)
    drop_table(:notifications_settings)
  end
end
