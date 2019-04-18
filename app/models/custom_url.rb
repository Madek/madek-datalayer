class CustomUrl < ApplicationRecord
  belongs_to :media_entry
  belongs_to :collection
  belongs_to :filter_set

  belongs_to :creator, class_name: 'User', foreign_key: :creator_id
  belongs_to :updator, class_name: 'User', foreign_key: :updator_id

  default_scope { reorder(id: :asc) }
end
