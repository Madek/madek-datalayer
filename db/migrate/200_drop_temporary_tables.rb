class DropTemporaryTables < ActiveRecord::Migration[4.2]
  def change
    # drop tables here that needed to be around for constraints
    drop_table :applications
  end
end
