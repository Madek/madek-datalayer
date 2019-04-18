class CreateFilterSetUserPermission < ActiveRecord::Migration[4.2]

  include Madek::MigrationHelper

  class ::MigrationUserPermission < ActiveRecord::Base
    self.table_name = :userpermissions
  end

  class ::MigrationFilterSetUserPermission < ActiveRecord::Base
    self.table_name = :filter_set_user_permissions
  end

  USER_PERMISSION_KEYS_MAP = {
    'view' => 'get_metadata_and_previews',
    'edit' => 'edit_metadata_and_filter',
    'manage' => 'edit_permissions' }

  def change
    create_table :filter_set_user_permissions, id: false do |t|
      t.primary_key :id, :uuid, default: 'gen_random_uuid()'

      t.boolean :get_metadata_and_previews, null: false, default: false, index: true
      t.boolean :edit_metadata_and_filter, null: false, default: false, index: true
      t.boolean :edit_permissions, null: false, default: false, index: true

      t.uuid :filter_set_id, null: false
      t.index :filter_set_id

      t.uuid :user_id, null: false
      t.index :user_id

      t.uuid :updator_id
      t.index :updator_id

      t.index [:filter_set_id, :user_id], unique: true, name: 'idx_fsetusrp_on_filter_set_id_and_user_id'

      t.timestamps null: false
    end

    add_foreign_key :filter_set_user_permissions, :users, on_delete: :cascade
    add_foreign_key :filter_set_user_permissions, :filter_sets, on_delete: :cascade
    add_foreign_key :filter_set_user_permissions, :users, column: 'updator_id'

  end

end
