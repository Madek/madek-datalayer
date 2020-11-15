class CreateDelegations < ActiveRecord::Migration[5.2]
  def change
    create_table :delegations, id: :uuid do |t|
      t.string :name, null: false
      t.text :description
      t.text :admin_comment
    end

    add_index :delegations, :name, unique: true

    create_table :delegations_groups, id: false do |t|
      t.belongs_to :delegation, index: true, type: :uuid, null: false
      t.belongs_to :group, index: true, type: :uuid, null: false
    end

    add_foreign_key :delegations_groups, :delegations
    add_foreign_key :delegations_groups, :groups
    add_index :delegations_groups, [:delegation_id, :group_id], unique: true

    create_table :delegations_users, id: false do |t|
      t.belongs_to :delegation, index: true, type: :uuid, null: false
      t.belongs_to :user, index: true, type: :uuid, null: false
    end

    add_foreign_key :delegations_users, :delegations
    add_foreign_key :delegations_users, :users
    add_index :delegations_users, [:delegation_id, :user_id], unique: true

    add_reference :media_entries, :responsible_delegation, foreign_key: { to_table: :delegations }, type: :uuid
    add_reference :collections, :responsible_delegation, foreign_key: { to_table: :delegations }, type: :uuid
    add_reference :filter_sets, :responsible_delegation, foreign_key: { to_table: :delegations }, type: :uuid

    change_column_null :media_entries, :responsible_user_id, true
    change_column_null :collections, :responsible_user_id, true
    change_column_null :filter_sets, :responsible_user_id, true

    reversible do |dir|
      constraint_name = 'one_responsible_column_is_not_null_at_the_same_time'
      table_names = %w(media_entries collections filter_sets)

      dir.up do
        table_names.each do |table_name|
          execute <<-SQL.strip_heredoc
            ALTER TABLE #{table_name}
            ADD CONSTRAINT #{constraint_name}
            CHECK (
              (responsible_user_id IS NULL AND responsible_delegation_id IS NOT NULL) OR
              (responsible_user_id IS NOT NULL AND responsible_delegation_id IS NULL)
            )
          SQL
        end
      end

      dir.down do
        table_names.each do |table_name|
          execute "ALTER TABLE #{table_name} DROP CONSTRAINT #{constraint_name}"
        end
      end
    end
  end
end
