class CreatePreviews < ActiveRecord::Migration[4.2]
  include Madek::MigrationHelper

  def change
    create_table :previews, id: false do |t|
      t.primary_key :id, :uuid, default: 'gen_random_uuid()'

      t.uuid :media_file_id, null: false
      t.index :media_file_id

      t.integer :height
      t.integer :width
      t.string :content_type
      t.string :filename
      t.string :thumbnail

      t.timestamps null: false

      t.string :media_type, null: false
      t.index :media_type

    end

    add_index :previews, :created_at

    reversible do |dir|
      dir.up do
        set_timestamps_defaults :media_resources
      end
    end

    add_foreign_key :previews, :media_files, on_delete: :cascade
  end
end
