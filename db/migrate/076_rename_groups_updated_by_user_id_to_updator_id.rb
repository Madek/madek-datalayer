class RenameGroupsUpdatedByUserIdToUpdatorId < ActiveRecord::Migration[7.2]
  def up
    remove_foreign_key :groups, column: :created_by_user_id

    rename_column :groups, :created_by_user_id, :creator_id
    add_column :groups, :updator_id, :uuid

    add_foreign_key :groups, :users, column: :updator_id, name: :fk_groups_updator_id
    add_foreign_key :groups, :users, column: :creator_id, name: :fk_groups_creator_id
  end

  def down
    remove_foreign_key :groups, column: :updator_id
    remove_foreign_key :groups, column: :creator_id

    remove_column :groups, :updator_id
    rename_column :groups, :creator_id, :created_by_user_id

    add_foreign_key :groups, :users, column: :created_by_user_id, name: :fk_groups_created_by_user_id
  end
end
