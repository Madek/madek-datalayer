class AddIsAssignableToGroups < ActiveRecord::Migration[7.2]
  def change
    add_column :groups, :is_assignable, :boolean, null: false, default: true
  end
end
