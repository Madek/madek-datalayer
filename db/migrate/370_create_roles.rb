class CreateRoles < ActiveRecord::Migration
  include Madek::MigrationHelper

  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')

    create_table :roles, id: false do |t|
      t.primary_key :id, :uuid, default: 'gen_random_uuid()'
      t.hstore :labels, default: '', null: false
      t.string :meta_key_id, index: true, null: false
      t.uuid :creator_id, index: true
      t.timestamps null: false
    end
    set_timestamps_defaults :roles

    add_index :roles, :labels, unique: true
  end
end
