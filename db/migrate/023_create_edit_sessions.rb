class CreateEditSessions < ActiveRecord::Migration[4.2]
  include Madek::MigrationHelper

  def change
    create_table :edit_sessions, id: false do |t|
      t.primary_key :id, :uuid, default: 'gen_random_uuid()'
      t.uuid :user_id, null: false
      t.index :user_id

      t.uuid :media_resource_id, null: false
      t.index :media_resource_id

      t.timestamps null: false
    end

    reversible do |dir|
      dir.up do
        set_timestamps_defaults :edit_sessions
      end
    end

    add_foreign_key :edit_sessions, :media_resources, on_delete: :cascade
    add_foreign_key :edit_sessions, :users, on_delete: :cascade
  end

end
