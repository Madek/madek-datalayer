class AddCreatorIdToVocabPermissions < ActiveRecord::Migration[7.2]
  include Madek::MigrationHelper

  def change
    [:vocabulary_api_client_permissions,
     :vocabulary_user_permissions,
     :vocabulary_group_permissions].each do |table|
       add_column table, :creator_id, :uuid
       add_foreign_key table, :users, column: :creator_id

       add_column table, :updator_id, :uuid
       add_foreign_key table, :users, column: :updator_id

       add_auto_timestamps table
     end
  end
end
