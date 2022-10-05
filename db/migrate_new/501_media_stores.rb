class MediaStores < ActiveRecord::Migration[5.2]
  include Madek::MigrationHelper

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
          ALTER TABLE media_stores
            ADD CONSTRAINT check_at_most_one_database
            CHECK (type <> 'database' OR (id = 'database' AND type = 'database'));
        SQL
      end
    end

    add_auto_timestamps :media_stores

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
        legacy_fs = MediaStore.create type: :filesystem,
          id: 'legacy-file-store',
          configuration: {
            originals_storage_dir: Madek::Constants::FILE_STORAGE_DIR,
            previews_storage_dir: Madek::Constants::THUMBNAIL_STORAGE_DIR,
            uploads_storage_dir: \
              Pathname.new(Madek::Constants::FILE_STORAGE_DIR) \
                .join("..").join("uploads").to_s }

        MediaFile.in_batches.each do |mfs|
          mfs.each do |mf|
            mf.update_attributes(media_store_id: legacy_fs.id)
          end
        end

        signed_in_users_group = Group.find_by(id: Madek::Constants::SIGNED_IN_USERS_GROUP_ID)

        if signed_in_users_group
          execute <<-SQL.strip_heredoc
            INSERT INTO media_stores_groups
              (group_id, media_store_id, priority)
              VALUES ('#{signed_in_users_group.id}', '#{legacy_fs.id}', 1);
          SQL
        end

        db_fs = MediaStore.create type: :database,
          id: 'database'

        if signed_in_users_group
          execute <<-SQL.strip_heredoc
            INSERT INTO media_stores_groups
              (group_id, media_store_id, priority)
              VALUES ('#{signed_in_users_group.id}', '#{db_fs.id}', 3);
          SQL
        end

      end
    end
  end

end
