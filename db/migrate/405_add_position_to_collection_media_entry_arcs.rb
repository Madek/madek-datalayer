class AddPositionToCollectionMediaEntryArcs < ActiveRecord::Migration[5.2]
  def change
    add_column :collection_media_entry_arcs, :position, :integer

    add_index :collection_media_entry_arcs, [:collection_id, :position]
  end
end
