class AddApiTokens < ActiveRecord::Migration[4.2]
  include Madek::MigrationHelper

  def change

    create_table :api_tokens, id: :uuid do |t|
      t.uuid :user_id, null: false
      t.string :token_hash, null: false, limit: 45
      t.string :token_part, null: false, limit: 5
      t.boolean :revoked, default: false, null: false
      t.boolean :scope_read, default: true, null: false
      t.boolean :scope_write, default: false, null: false
      t.text :description
    end

    add_auto_timestamps :api_tokens

    add_foreign_key :api_tokens, :users , on_delete: :cascade, on_update: :cascade

    add_column :api_tokens, :expires_at, 'timestamp with time zone', null: false


    reversible do |dir|
      dir.up do
        execute "ALTER TABLE api_tokens ALTER COLUMN expires_at SET DEFAULT now() + interval '1 year'"
        execute 'ALTER TABLE api_tokens ADD UNIQUE ("token_hash")'
      end
    end


  end
end
