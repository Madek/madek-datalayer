class NotifColumnsForDelegations < ActiveRecord::Migration[6.1]
  def change
    add_column :delegations, :notifications_email, :string
    add_column :delegations, :notify_all_members, :boolean, default: true, null: false

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE delegations
          ADD CONSTRAINT notifications_email_check
          CHECK (notifications_email::text ~~* '%@%'::text OR notifications_email IS NULL);
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE delegations
          DROP CONSTRAINT notifications_email_check;
        SQL
      end
    end
  end
end
