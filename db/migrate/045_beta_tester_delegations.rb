class BetaTesterDelegations < ActiveRecord::Migration[6.1]
  def change
    add_column :delegations, :beta_tester_notifications, :boolean, default: false, null: false
  end
end
