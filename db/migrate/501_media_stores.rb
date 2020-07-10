class MediaStores < ActiveRecord::Migration[5.2]

  class MediaStore < ApplicationRecord
    self.inheritance_column = :_type_disabled
  end

  def change

    create_table :media_stores, id: :text do |t|
      t.text :description
      t.jsonb :configuration
      t.text :type, null: false, default: 'database'
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL.strip_heredoc
          ALTER TABLE media_stores
            ADD CONSTRAINT check_allowed_types
            CHECK (
              type IN ('database', 'filesystem', 'S3' )
            );
        SQL
      end
    end

    create_table :media_stores_users, id: :uuid do |t|
      t.uuid :user_id, null: false
      t.index :user_id
      t.text :media_store_id, null: false
      t.index :media_store_id
      t.index [:user_id, :media_store_id], unique: true
      t.integer :priority, default: 0, null: false
    end

    add_foreign_key :media_stores_users, :users, cascade: :delete
    add_foreign_key :media_stores_users, :media_stores, cascade: :delete

    create_table :media_stores_groups, id: :uuid do |t|
      t.uuid :group_id, null: false
      t.index :group_id
      t.text :media_store_id, null: false
      t.index :media_store_id
      t.index [:group_id, :media_store_id], unique: true
      t.integer :priority, default: 0, null: false
    end

    add_foreign_key :media_stores_groups, :groups, cascade: :delete
    add_foreign_key :media_stores_groups, :media_stores, cascade: :delete


    add_column :media_files, :media_store_id, :text
    add_index :media_files, :media_store_id
    add_foreign_key :media_files, :media_stores

    reversible do |dir|
      dir.up do
        if MediaFile.count > 0
          ms = MediaStore.create type: :filesystem,
            id: 'legacy-file-store',
            configuration: {
              originals_storage_dir: Madek::Constants::FILE_STORAGE_DIR,
              previews_storage_dir: Madek::Constants::THUMBNAIL_STORAGE_DIR }

          MediaFile.in_batches.each do |mfs|
            mfs.each do |mf|
              mf.update_attributes(media_store_id: ms.id)
            end
          end

        end

      end
    end
  end

end
