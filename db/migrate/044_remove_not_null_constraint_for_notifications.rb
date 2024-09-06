class RemoveNotNullConstraintForNotifications < ActiveRecord::Migration[6.1]
  def change
    change_column :notifications, :user_id, :uuid, null: true
  end
end
