class AddOrderFieldToCollectionArcs < ActiveRecord::Migration[5.2]
  include Madek::MigrationHelper

  def change
    add_column :collection_media_entry_arcs, :order, :float, default: nil
    add_index :collection_media_entry_arcs, [:collection_id, :order], name: :collection_media_entry_idx
    add_auto_timestamps :collection_media_entry_arcs

    add_column :collection_collection_arcs, :order, :float, default: nil
    add_index :collection_collection_arcs, [:parent_id, :order], name:  :collection_collection_idx
    add_auto_timestamps :collection_collection_arcs
  end
end
