class AddApiTokens < ActiveRecord::Migration
  include Madek::MigrationHelper

  def change

    create_table :api_tokens, id: :text do |t|
      t.uuid :user_id, null: false
      t.boolean :revoked, default: false, null: false
      t.boolean :scope_read, default: true, null: false
      t.boolean :scope_write, default: false, null: false
      t.text :description
    end

    add_auto_timestamps :api_tokens

    add_foreign_key :api_tokens, :users , on_delete: :cascade, on_update: :cascade

  end
end
