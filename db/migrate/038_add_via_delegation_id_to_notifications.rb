class AddViaDelegationIdToNotifications < ActiveRecord::Migration[6.1]
  def change
    add_column :notifications, :via_delegation_id, :uuid
    add_foreign_key :notifications, :delegations, column: :via_delegation_id
  end
end
