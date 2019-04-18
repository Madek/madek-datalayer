class AddForeignKeysToCollectionUserPermissions < ActiveRecord::Migration[4.2]

  def change
    add_foreign_key :collection_user_permissions, :users, on_delete: :cascade
    add_foreign_key :collection_user_permissions, :collections, on_delete: :cascade
    add_foreign_key :collection_user_permissions, :users, column: 'updator_id'
  end

end
