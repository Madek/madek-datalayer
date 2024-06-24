class NotifColumnsForDelegations < ActiveRecord::Migration[6.1]
  def change
    add_column :delegations, :notifications_email, :string
    add_column :delegations, :notify_all_members, :boolean, default: true, null: false
  end
end
