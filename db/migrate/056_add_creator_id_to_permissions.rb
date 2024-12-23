class AddCreatorIdToPermissions < ActiveRecord::Migration[7.2]
  TABLES = %w[
    media_entry_api_client_permissions
    media_entry_user_permissions
    media_entry_group_permissions
    collection_api_client_permissions
    collection_user_permissions
    collection_group_permissions
  ]

  def change
    TABLES.each do |table|
      add_column table, :creator_id, :uuid
    end
  end
end
