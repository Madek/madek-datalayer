class AddContextPermissions < ActiveRecord::Migration[7.2]
  include Madek::MigrationHelper

  def up
    add_column :contexts, :enabled_for_public_view, :boolean, null: false, default: true
    add_column :contexts, :enabled_for_public_use, :boolean, null: false, default: true

    create_table :context_user_permissions, id: :uuid do |t|
      t.uuid :user_id, null: false
      t.string :context_id, null: false
      t.boolean :use, null: false, default: false
      t.boolean :view, null: false, default: true
      t.uuid :creator_id
      t.uuid :updator_id
    end
    add_auto_timestamps :context_user_permissions
    add_foreign_key :context_user_permissions, :users, column: :user_id, on_delete: :restrict
    add_foreign_key :context_user_permissions, :contexts, column: :context_id, on_delete: :cascade
    add_index :context_user_permissions, [:user_id, :context_id], unique: true, name: 'idx_context_user'

    create_table :context_group_permissions, id: :uuid do |t|
      t.uuid :group_id, null: false
      t.string :context_id, null: false
      t.boolean :use, null: false, default: false
      t.boolean :view, null: false, default: true
      t.uuid :creator_id
      t.uuid :updator_id
    end
    add_auto_timestamps :context_group_permissions
    add_foreign_key :context_group_permissions, :groups, column: :group_id, on_update: :cascade, on_delete: :cascade
    add_foreign_key :context_group_permissions, :contexts, column: :context_id, on_delete: :cascade
    add_index :context_group_permissions, [:group_id, :context_id], unique: true, name: 'idx_context_group'

    create_table :context_api_client_permissions, id: :uuid do |t|
      t.uuid :api_client_id, null: false
      t.string :context_id, null: false
      t.boolean :use, null: false, default: false
      t.boolean :view, null: false, default: true
      t.uuid :creator_id
      t.uuid :updator_id
    end
    add_auto_timestamps :context_api_client_permissions
    add_foreign_key :context_api_client_permissions, :api_clients, column: :api_client_id, on_delete: :cascade
    add_foreign_key :context_api_client_permissions, :contexts, column: :context_id, on_delete: :cascade
    add_index :context_api_client_permissions, [:api_client_id, :context_id], unique: true, name: 'idx_context_api_client'

    [:context_user_permissions,
     :context_group_permissions,
     :context_api_client_permissions].each do |table|
      execute <<-SQL.strip_heredoc
        CREATE TRIGGER #{table}_audit_change
        AFTER INSERT OR DELETE OR UPDATE ON #{table}
        FOR EACH ROW EXECUTE FUNCTION audit_change();
      SQL
    end
  end

  def down
    drop_table :context_api_client_permissions
    drop_table :context_group_permissions
    drop_table :context_user_permissions
    remove_column :contexts, :enabled_for_public_use
    remove_column :contexts, :enabled_for_public_view
  end
end
