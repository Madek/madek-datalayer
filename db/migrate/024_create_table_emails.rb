class CreateTableEmails < ActiveRecord::Migration[6.1]
  def change
    create_table :emails, id: :uuid do |t|
      t.uuid :user_id, null: false
      t.text :subject, null: false
      t.text :body, null: false
      t.text :from_address, null: false
      t.text :to_address, null: false
      t.integer :trials, null: false, default: 0
      t.boolean :is_successful
      t.text :error_message
      t.timestamps null: false, default: -> { 'NOW()' }
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE emails
          ADD CONSTRAINT check_trial_success_or_error
            CHECK (
              (trials = 0 AND is_successful IS NULL AND error_message IS NULL)
              OR (trials > 0 AND (
                (is_successful = TRUE AND error_message IS NULL) 
                OR (is_successful = FALSE AND error_message IS NOT NULL)
              ))
            )
        SQL

        execute <<-SQL
          CREATE OR REPLACE FUNCTION delete_old_emails_f()
          RETURNS TRIGGER AS $$
          BEGIN
            DELETE FROM emails WHERE created_at < CURRENT_DATE - INTERVAL '90 days';
            RETURN NEW;
          END;
          $$ language 'plpgsql';
        SQL

        execute <<-SQL
          CREATE CONSTRAINT TRIGGER delete_old_emails_t
          AFTER INSERT OR UPDATE
          ON emails
          FOR EACH ROW
          EXECUTE PROCEDURE delete_old_emails_f()
        SQL
      end

      dir.down do
        execute 'DROP TRIGGER delete_old_emails_t ON emails'
        execute 'DROP FUNCTION IF EXISTS delete_old_emails_f()'
      end
    end
  end
end
