class CreateMediaFiles < ActiveRecord::Migration[4.2]
  include Madek::MigrationHelper

  def change
    create_table :media_files, id: false do |t|
      t.primary_key :id, :uuid, default: 'gen_random_uuid()'
      t.integer :height
      t.integer :size
      t.integer :width

      t.text :access_hash
      t.text :meta_data

      t.string :content_type, null: false

      t.string :filename
      t.string :guid

      t.string :extension
      t.index :extension

      t.string :media_type
      t.index :media_type

      t.uuid :media_entry_id
      t.index :media_entry_id

      t.timestamps null: false

    end

    reversible do |dir|
      dir.up do
        change_column :media_files, :size, :bigint
        set_timestamps_defaults :media_files
      end
    end
  end

end
