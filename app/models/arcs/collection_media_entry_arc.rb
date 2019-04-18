module Arcs
  class CollectionMediaEntryArc < ApplicationRecord
    belongs_to :collection
    belongs_to :media_entry
  end
end
