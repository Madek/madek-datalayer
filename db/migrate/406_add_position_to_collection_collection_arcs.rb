class AddPositionToCollectionCollectionArcs < ActiveRecord::Migration[5.2]
  def change
    add_column :collection_collection_arcs, :position, :integer

    add_index :collection_collection_arcs, [:parent_id, :position]
  end
end
