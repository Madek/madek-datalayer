class CreateAdminUsers < ActiveRecord::Migration[4.2]
  include Madek::MigrationHelper

  def change
    create_table :admin_users, id: false do |t|
      t.primary_key :id, :uuid, default: 'gen_random_uuid()'

      t.uuid :user_id, null: false
      t.index :user_id, unique: true

      t.timestamps null: false
    end

    add_foreign_key :admin_users, :users, on_delete: :cascade

    reversible do |dir|
      dir.up do
        set_timestamps_defaults :admin_users
      end

    end
  end

end
