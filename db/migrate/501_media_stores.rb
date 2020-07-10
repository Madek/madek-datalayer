class MediaStores < ActiveRecord::Migration[5.2]

  def change

    create_table :media_stores, id: :uuid do |t|
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
      t.uuid :media_store_id, null: false
      t.index :media_store_id
      t.index [:user_id, :media_store_id], unique: true
      t.integer :priority, default: 0, null: false
    end

    add_foreign_key :media_stores_users, :users, cascade: :delete
    add_foreign_key :media_stores_users, :media_stores, cascade: :delete

    create_table :media_stores_groups, id: :uuid do |t|
      t.uuid :group_id, null: false
      t.index :group_id
      t.uuid :media_store_id, null: false
      t.index :media_store_id
      t.index [:group_id, :media_store_id], unique: true
      t.integer :priority, default: 0, null: false
    end

    add_foreign_key :media_stores_groups, :groups, cascade: :delete
    add_foreign_key :media_stores_groups, :media_stores, cascade: :delete


    add_column :media_files, :media_store_id, :uuid
    add_index :media_files, :media_store_id
    add_foreign_key :media_files, :media_stores


  end

end
