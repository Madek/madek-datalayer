class AddSignedInAtToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :last_signed_in_at, 'timestamp with time zone'
  end
end
