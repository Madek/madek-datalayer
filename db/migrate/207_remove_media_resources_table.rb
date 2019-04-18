class RemoveMediaResourcesTable < ActiveRecord::Migration[4.2]
  def change
    execute "DROP TABLE media_resources CASCADE"
  end
end
