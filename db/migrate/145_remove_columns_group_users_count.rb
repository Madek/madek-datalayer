class RemoveColumnsGroupUsersCount < ActiveRecord::Migration[4.2]
  def change
    remove_column :groups, :users_count, :integer
  end
end
