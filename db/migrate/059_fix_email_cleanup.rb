class FixEmailCleanup < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION delete_old_emails_f()
      RETURNS TRIGGER AS $$
      BEGIN
        DELETE FROM emails
        WHERE created_at < CURRENT_DATE - INTERVAL '90 days'
          AND NOT EXISTS (
            SELECT 1
            FROM notifications
            WHERE email_id = emails.id
        );

        RETURN NEW;
      END;
      $$ language 'plpgsql';
    SQL

    execute <<-SQL
      CREATE OR REPLACE FUNCTION delete_old_notifications_f()
      RETURNS TRIGGER AS $$
      BEGIN
        DELETE FROM notifications
        WHERE created_at < CURRENT_DATE - INTERVAL '180 days';

        DELETE FROM emails
        WHERE id IN (
          SELECT email_id
          FROM notifications
          WHERE created_at < CURRENT_DATE - INTERVAL '180 days'
        );

        RETURN NEW;
      END;
      $$ language 'plpgsql';
    SQL
  end
end
