class RenameGroupsUpdatedByUserIdToUpdatorId < ActiveRecord::Migration[7.2]
  def up
    if foreign_key_exists?(:groups, :users, column: :updated_by_user_id)
      remove_foreign_key :groups, column: :updated_by_user_id
    end

    if foreign_key_exists?(:groups, :users, column: :created_by_user_id)
      remove_foreign_key :groups, column: :created_by_user_id
    end

    if column_exists?(:groups, :updated_by_user_id) && !column_exists?(:groups, :updator_id)
      rename_column :groups, :updated_by_user_id, :updator_id
    end

    if column_exists?(:groups, :created_by_user_id) && !column_exists?(:groups, :creator_id)
      rename_column :groups, :created_by_user_id, :creator_id
    end

    unless column_exists?(:groups, :updator_id)
      add_column :groups, :updator_id, :uuid
    end

    if column_exists?(:groups, :updator_id) && !foreign_key_exists?(:groups, :users, column: :updator_id)
      add_foreign_key :groups, :users, column: :updator_id, name: :fk_groups_updator_id
    end

    if column_exists?(:groups, :creator_id) && !foreign_key_exists?(:groups, :users, column: :creator_id)
      add_foreign_key :groups, :users, column: :creator_id, name: :fk_groups_creator_id
    end
  end

  def down
    if foreign_key_exists?(:groups, :users, column: :updator_id)
      remove_foreign_key :groups, column: :updator_id
    end

    if foreign_key_exists?(:groups, :users, column: :creator_id)
      remove_foreign_key :groups, column: :creator_id
    end

    if column_exists?(:groups, :updator_id) && !column_exists?(:groups, :updated_by_user_id)
      rename_column :groups, :updator_id, :updated_by_user_id
    end

    if column_exists?(:groups, :creator_id) && !column_exists?(:groups, :created_by_user_id)
      rename_column :groups, :creator_id, :created_by_user_id
    end

    if column_exists?(:groups, :updated_by_user_id) && !foreign_key_exists?(:groups, :users, column: :updated_by_user_id)
      add_foreign_key :groups, :users, column: :updated_by_user_id, name: :fk_groups_updated_by_user_id
    end

    if column_exists?(:groups, :created_by_user_id) && !foreign_key_exists?(:groups, :users, column: :created_by_user_id)
      add_foreign_key :groups, :users, column: :created_by_user_id, name: :fk_groups_created_by_user_id
    end
  end
end
