module Arcs
  class CollectionCollectionArc < ApplicationRecord
    belongs_to :parent, class_name: 'Collection'
    belongs_to :child, class_name: 'Collection'
  end
end
