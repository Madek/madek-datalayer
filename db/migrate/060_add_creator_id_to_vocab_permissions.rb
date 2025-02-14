class AddCreatorIdToVocabPermissions < ActiveRecord::Migration[7.2]
  def change
    [:vocabulary_api_client_permissions,
     :vocabulary_user_permissions,
     :vocabulary_group_permissions].each do |table|
       add_column table, :creator_id, :uuid
       add_foreign_key table, :users, column: :creator_id
     end
  end
end
