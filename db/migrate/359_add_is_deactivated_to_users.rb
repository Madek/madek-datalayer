class AddIsDeactivatedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_deactivated, :boolean, default: false
  end
end
