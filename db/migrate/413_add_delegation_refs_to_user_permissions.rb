class AddDelegationRefsToUserPermissions < ActiveRecord::Migration[5.2]
  TABLE_NAMES = %i(
    media_entry_user_permissions
    collection_user_permissions
    filter_set_user_permissions
  ).freeze
  CONSTRAINT_NAME = "user_id_or_delegation_id_not_null_at_the_same_time".freeze

  def change
    TABLE_NAMES.each do |table_name|
      add_reference table_name, :delegation, foreign_key: true, type: :uuid

      change_column_null table_name, :user_id, true
    end

    reversible do |dir|
      dir.up do
        TABLE_NAMES.each do |table_name|
          execute <<-SQL.strip_heredoc
            ALTER TABLE #{table_name}
            ADD CONSTRAINT #{CONSTRAINT_NAME}
            CHECK (
              (user_id IS NOT NULL AND delegation_id IS NULL) OR
              (user_id IS NULL AND delegation_id IS NOT NULL)
            )
          SQL
        end
      end

      dir.down do
        TABLE_NAMES.each do |table_name|
          execute "ALTER TABLE #{table_name} DROP CONSTRAINT #{CONSTRAINT_NAME}"
        end
      end
    end
  end
end
