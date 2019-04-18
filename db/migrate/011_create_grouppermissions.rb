class CreateGrouppermissions < ActiveRecord::Migration[4.2]
  include Madek::MigrationHelper
  include Madek::Constants

  def change
    create_table :grouppermissions, id: false do |t|
      t.primary_key :id, :uuid, default: 'gen_random_uuid()'

      t.uuid :media_resource_id, null: false
      t.index :media_resource_id

      t.uuid :group_id, null: false
      t.index :group_id

      t.index [:group_id, :media_resource_id]

      MADEK_V2_PERMISSION_ACTIONS.each do |action|
        t.boolean action, null: false, default: false, index: true
      end

    end

    reversible do |dir|
      dir.up do
        execute 'ALTER TABLE grouppermissions ADD CONSTRAINT manage_on_grouppermissions_is_false CHECK (manage = false); '
      end
    end

    add_foreign_key :grouppermissions, :groups, on_delete: :cascade
    add_foreign_key :grouppermissions, :media_resources, on_delete: :cascade
  end

end
