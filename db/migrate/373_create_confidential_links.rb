class CreateConfidentialLinks < ActiveRecord::Migration[4.2]
  include Madek::MigrationHelper

  def change
    create_table :confidential_links, id: :uuid do |t|
      t.uuid :user_id, null: false
      t.references :resource, polymorphic: true, index: true, type: :uuid
      t.string :token, null: false, limit: 45
      t.boolean :revoked, default: false, null: false
      t.text :description
    end

    add_auto_timestamps :confidential_links

    add_foreign_key :confidential_links, :users, on_delete: :cascade, on_update: :cascade

    add_column :confidential_links, :expires_at, 'timestamp with time zone'
  end
end
