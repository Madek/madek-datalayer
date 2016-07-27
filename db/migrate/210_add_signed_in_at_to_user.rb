class AddSignedInAtToUser < ActiveRecord::Migration
  def change
    add_column :users, :last_signed_in_at, 'timestamp with time zone'
  end
end
