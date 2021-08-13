class Uploads < ActiveRecord::Migration[5.2]
  include Madek::MigrationHelper

  def up
    create_table :uploads, id: :uuid

    add_column :uploads, :md5, :text
    add_column :uploads, :sha256, :text

    add_column :uploads, :uploader_id, :uuid, null: false
    add_index :uploads, :uploader_id
    add_foreign_key :uploads, :users, column: :uploader_id

    add_column :uploads, :size, :int, null: false
    add_column :uploads, :content_type, :text, null: false, default: 'application/octet-stream'
    add_column :uploads, :filename, :text

    add_column :uploads, :error, :text

    add_column :uploads, :state, :text, null: false, default: 'announced'
    execute <<-SQL.strip_heredoc
      ALTER TABLE uploads ADD CONSTRAINT valid_state
        CHECK (state IN ('announced', 'started', 'completed', 'finished', 'failed'));
    SQL

    add_column :uploads, :media_store_id, :text, null: false
    add_foreign_key :uploads, :media_stores

    add_column :uploads, :media_file_id, :uuid
    add_index :uploads, :media_file_id, unique: true
    add_foreign_key :uploads, :media_files

    add_auto_timestamps :uploads


    ### media_file ###############################################################

    add_column :media_files, :sha256, :text


    ### upload_parts ###############################################################

    create_table :media_file_parts, id: :uuid
    add_column :media_file_parts, :blob, :bytea, null: false
    add_column :media_file_parts, :part, :int
    add_column :media_file_parts, :start, :int
    add_column :media_file_parts, :size, :int

    add_column :media_file_parts, :md5, :text #, null: false
    add_column :media_file_parts, :sha256, :text #, null: false

    add_column :media_file_parts, :upload_id, :uuid
    add_index :media_file_parts, [:upload_id, :part], unique: true
    add_foreign_key :media_file_parts, :uploads, cascade: :nullify

    add_column :media_file_parts, :media_file_id, :uuid
    add_index :media_file_parts, [:media_file_id, :part], unique: true
    add_foreign_key :media_file_parts, :media_files, cascade: :delete

    add_auto_timestamps :media_file_parts

    execute <<-SQL.strip_heredoc
      CREATE OR REPLACE FUNCTION set_properties_media_file_parts()
      RETURNS trigger AS $$
      BEGIN
        NEW.md5 = md5(NEW.blob);
        NEW.sha256 = encode(digest(NEW.blob, 'sha256'), 'hex');
        NEW.size = length(NEW.blob);
        RETURN NEW;
      END;
      $$ language 'plpgsql';


      CREATE TRIGGER set_properties_media_file_parts
        BEFORE INSERT OR UPDATE
        ON media_file_parts
        FOR EACH ROW
        EXECUTE PROCEDURE set_properties_media_file_parts();
    SQL


  end

  def down
    remove_column :media_files, :sha256, :text
    # remove_foreign_key :media_files, :uploads
    # remove_column :media_files, :upload_id, :uuid, null: false

    execute 'DROP TRIGGER set_properties_media_file_parts ON media_file_parts'
    execute 'DROP FUNCTION set_properties_media_file_parts()'
    execute 'DROP TABLE media_file_parts'
    execute 'DROP TABLE uploads CASCADE'
  end

end


