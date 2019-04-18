class AddNullRestrictionToCreatorId < ActiveRecord::Migration[4.2]
  def change
    change_column :media_entries, :creator_id, :uuid, null: false
  end
end
