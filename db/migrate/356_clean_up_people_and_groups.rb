class CleanUpPeopleAndGroups < ActiveRecord::Migration[4.2]
  include Madek::MigrationHelper

  def up

    execute <<-SQL
      DROP TRIGGER update_searchable_column_of_groups ON groups;
      DROP FUNCTION groups_update_searchable_column();
    SQL


    change_column :groups, :name, :text, null: false
    rename_column :groups, :institutional_group_id, :institutional_id
    rename_column :groups, :institutional_group_name, :institutional_name
    remove_column :groups, :previous_id

    auto_update_searchable :groups, [:name, :institutional_name]

    add_index :people, :institutional_id, unique: true
    remove_column :people, :date_of_birth
    remove_column :people, :date_of_death

  end

end
