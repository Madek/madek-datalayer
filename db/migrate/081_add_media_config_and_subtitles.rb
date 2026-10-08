class AddMediaConfigAndSubtitles < ActiveRecord::Migration[7.2]
  include Madek::MigrationHelper

  def change
    add_column :media_files, :media_config, :jsonb, null: false, default: {}

    create_table :subtitles, id: :uuid do |t|
      t.uuid :media_file_id, null: false
      t.string :language, null: false
      t.string :label
      t.string :kind, null: false, default: 'subtitles'
      t.string :filename, null: false
      t.text :content, null: false
      t.boolean :is_default, null: false, default: false
    end

    add_auto_timestamps :subtitles, null: false
    add_index :subtitles, :media_file_id
    add_index :subtitles,
              [:media_file_id, :kind, :language],
              unique: true,
              name: 'index_subtitles_on_media_file_kind_language'
    add_index :subtitles,
              [:media_file_id, :kind],
              unique: true,
              where: 'is_default',
              name: 'index_subtitles_one_default_per_kind'

    reversible do |dir|
      dir.up do
        execute <<~SQL
          ALTER TABLE subtitles
          ADD CONSTRAINT subtitles_media_files_fkey
          FOREIGN KEY (media_file_id) REFERENCES media_files(id) ON DELETE CASCADE
        SQL
        execute <<~SQL
          ALTER TABLE subtitles
          ADD CONSTRAINT subtitles_kind_check
          CHECK (kind IN ('subtitles', 'chapters'))
        SQL
      end
    end
  end
end
