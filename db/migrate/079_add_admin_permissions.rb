class AddAdminPermissions < ActiveRecord::Migration[7.2]
  include Madek::MigrationHelper

  PERMISSION_KEYS = %w(
    people
    users
    manage_admin_permissions
    groups
    delegations
    roles
    keywords
    vocabularies
    contexts
    meta_data
    entries
    sets
    usage_terms
    sql_assistant
    api_clients
    io
    notifications
    settings
    smtp
    uberadmin_view
    uberadmin_edit
  ).freeze

  def up
    create_table :admin_permissions, id: :uuid do |t|
      t.uuid :admin_id, null: false
      t.string :permission_key, null: false
      t.uuid :creator_id
      t.uuid :updator_id
    end
    add_auto_timestamps :admin_permissions
    add_foreign_key :admin_permissions, :admins, column: :admin_id, on_delete: :cascade
    add_index :admin_permissions, [:admin_id, :permission_key], unique: true, name: 'idx_admin_permission'

    execute <<-SQL.strip_heredoc
      CREATE TRIGGER admin_permissions_audit_change
      AFTER INSERT OR DELETE OR UPDATE ON admin_permissions
      FOR EACH ROW EXECUTE FUNCTION audit_change();
    SQL

    # Grant all existing admins all permissions, so nobody loses access on
    # deploy and the first `manage_admin_permissions` holder(s) already exist.
    execute <<-SQL.strip_heredoc
      INSERT INTO admin_permissions (id, admin_id, permission_key, created_at, updated_at)
      SELECT gen_random_uuid(), admins.id, keys.key, now(), now()
      FROM admins, unnest(ARRAY[#{PERMISSION_KEYS.map { |k| "'#{k}'" }.join(', ')}]) AS keys(key)
    SQL
  end

  def down
    drop_table :admin_permissions
  end
end
