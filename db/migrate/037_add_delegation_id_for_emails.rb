class AddDelegationIdForEmails < ActiveRecord::Migration[6.1]
  def change
    change_column_null :emails, :user_id, true
    add_column :emails, :delegation_id, :uuid
    add_foreign_key :emails, :delegations, column: :delegation_id
    add_foreign_key :emails, :users, column: :user_id

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE emails
          ADD CONSTRAINT emails_user_id_or_delegation_id
          CHECK (user_id IS NOT NULL OR delegation_id IS NOT NULL)
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE emails
          DROP CONSTRAINT emails_user_id_or_delegation_id
        SQL
      end
    end
  end
end
