class AddIsDeactivatedToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :is_deactivated, :boolean, default: false
  end
end
