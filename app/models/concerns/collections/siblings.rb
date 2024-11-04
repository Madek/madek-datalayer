module Collections
  module Siblings

    def sibling_collections
      Collection
        .joins(:collection_collection_arcs_as_child)
        .where(collection_collection_arcs: {
          parent_id: parent_collections.select(:id).reorder(nil)
        })
        .where.not(collections: { id: self.id })
    end

  end
end
