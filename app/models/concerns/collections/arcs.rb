module Concerns
  module Collections
    module Arcs
      extend ActiveSupport::Concern

      included do
        has_many :collection_media_entry_arcs,
                 class_name: '::Arcs::CollectionMediaEntryArc'

        has_many :collection_media_entry_highlighted_arcs,
                 -> { where(highlight: true) },
                 class_name: '::Arcs::CollectionMediaEntryArc'

        has_many :collection_collection_arcs_as_parent,
                 class_name: '::Arcs::CollectionCollectionArc',
                 foreign_key: :parent_id

        has_many :collection_collection_arcs_as_child,
                 class_name: '::Arcs::CollectionCollectionArc',
                 foreign_key: :child_id

        has_many :collection_collection_highlighted_arcs,
                 -> { where(highlight: true) },
                 class_name: '::Arcs::CollectionCollectionArc',
                 foreign_key: :parent_id

        has_many :collection_filter_set_arcs,
                 class_name: '::Arcs::CollectionFilterSetArc'

        has_many :collection_filter_set_highlighted_arcs,
                 -> { where(highlight: true) },
                 class_name: '::Arcs::CollectionFilterSetArc'
      end
    end
  end
end
