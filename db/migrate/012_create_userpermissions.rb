class CreateUserpermissions < ActiveRecord::Migration[4.2]
  include Madek::Constants

  def change
    create_table :userpermissions, id: false do |t|
      t.primary_key :id, :uuid, default: 'gen_random_uuid()'

      MADEK_V2_PERMISSION_ACTIONS.each do |action|
        t.boolean action, null: false, default: false, index: true
      end

      t.uuid :media_resource_id, null: false
      t.index :media_resource_id

      t.uuid :user_id, null: false
      t.index :user_id

      t.index [:media_resource_id, :user_id]

    end

    add_foreign_key :userpermissions, :users, on_delete: :cascade
    add_foreign_key :userpermissions, :media_resources, on_delete: :cascade
  end

end
