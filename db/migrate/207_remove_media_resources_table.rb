class RemoveMediaResourcesTable < ActiveRecord::Migration
  def change
    execute "DROP TABLE media_resources CASCADE"
  end
end
