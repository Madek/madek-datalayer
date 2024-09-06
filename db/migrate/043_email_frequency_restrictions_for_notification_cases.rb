class EmailFrequencyRestrictionsForNotificationCases < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      ALTER TABLE notification_cases_users_settings
      DROP CONSTRAINT check_email_regularity_value;
    SQL

    add_column(:notification_cases, :allowed_email_frequencies, :text,
               array: true, default: [], null: false)
    
    execute <<-SQL
      UPDATE notification_cases
      SET allowed_email_frequencies = ARRAY['never', 'daily', 'weekly']
      WHERE label = 'transfer_responsibility';
    SQL

    execute <<-SQL
      CREATE OR REPLACE FUNCTION check_email_frequency_for_notification_case_f()
      RETURNS TRIGGER AS $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1
          FROM notification_cases
          WHERE label = NEW.notification_case_label
          AND NEW.email_frequency = ANY(allowed_email_frequencies)
        ) THEN
          RAISE EXCEPTION 'Invalid email frequency: %', NEW.email_frequency;
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER check_email_frequency_for_notification_case_t
      BEFORE INSERT OR UPDATE ON notification_cases_users_settings
      FOR EACH ROW EXECUTE FUNCTION check_email_frequency_for_notification_case_f();
    SQL
  end
end
