class CreateApplications < ActiveRecord::Migration[4.2]
  include Madek::MigrationHelper

  def change
    create_table :applications, id: false do |t|
      t.uuid :user_id, null: false
      t.string :id, null: false, primary_key: true
      t.text :description
      t.uuid :secret, default: 'gen_random_uuid()', null: false
      t.timestamps null: false
    end

    add_foreign_key :applications, :users

    reversible do |dir|
      dir.up do
        set_timestamps_defaults :applications
      end
    end
  end

end
