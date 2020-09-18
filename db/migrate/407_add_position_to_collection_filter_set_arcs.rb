class AddPositionToCollectionFilterSetArcs < ActiveRecord::Migration[5.2]
  def change
    add_column :collection_filter_set_arcs, :position, :integer

    add_index :collection_filter_set_arcs, [:collection_id, :position]
  end
end
