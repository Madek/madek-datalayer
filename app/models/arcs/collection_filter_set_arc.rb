module Arcs
  class CollectionFilterSetArc < ApplicationRecord
    belongs_to :collection
    belongs_to :filter_set
  end
end
