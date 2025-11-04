class UserDeleteRestrictConditions < ActiveRecord::Migration[7.2]
  CASCADE_FKEYS = [[:delegations_supervisors, :user_id],
                   [:vocabulary_user_permissions, :user_id]]

  SET_NULL_FKEYS = [[:collection_api_client_permissions, :updator_id],
                    [:collection_group_permissions, :updator_id],
                    [:collection_user_permissions, :updator_id],
                    [:custom_urls, :creator_id],
                    [:custom_urls, :updator_id],
                    [:media_entry_api_client_permissions, :updator_id],
                    [:media_entry_group_permissions, :updator_id],
                    [:media_entry_user_permissions, :updator_id],
                    [:meta_data, :created_by_id],
                    [:meta_data_keywords, :created_by_id],
                    [:meta_data_people, :created_by_id],
                    [:roles, :creator_id],
                    [:vocabulary_api_client_permissions, :creator_id],
                    [:vocabulary_api_client_permissions, :updator_id],
                    [:vocabulary_group_permissions, :creator_id],
                    [:vocabulary_group_permissions, :updator_id],
                    [:vocabulary_user_permissions, :creator_id],
                    [:vocabulary_user_permissions, :updator_id],
                    [:people, :creator_id],
                    [:people, :updator_id],
                    [:users, :creator_id],
                    [:users, :updator_id]]

  def change
    CASCADE_FKEYS.each do |table, column|
      remove_foreign_key table, column: column
      add_foreign_key table, :users, column: column, on_delete: :restrict
    end

    SET_NULL_FKEYS.each do |table, column|
      remove_foreign_key table, column: column
    end
  end
end
