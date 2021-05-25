class Uploads < ActiveRecord::Migration[5.2]

  def up
    create_table :uploads, id: :uuid

    add_column :uploads, :md5, :text, null: false

    add_column :uploads, :uploader, :uuid, null: false
    add_foreign_key :uploads, :users, column: :uploader

    add_column :uploads, :size, :int, null: false

    add_column :uploads, :state, :text, null: false, default: 'announced'
    execute <<-SQL.strip_heredoc
      ALTER TABLE uploads ADD CONSTRAINT valid_state
        CHECK (state IN ('announced', 'uploading'));
    SQL

    add_column :uploads, :media_store_id, :text, null: false
    add_foreign_key :uploads, :media_stores


    ### upload_parts ###############################################################

    create_table :upload_parts, id: :uuid
    add_column :upload_parts, :upload_id, :uuid, null: false
    add_foreign_key :upload_parts, :uploads
    add_column :upload_parts, :idx, :int, null: false
    add_column :upload_parts, :size, :int, null: false
    add_column :upload_parts, :md5, :text, null: false


  end

  def down
    execute 'DROP TABLE upload_parts'
    execute 'DROP TABLE uploads'
  end

end


