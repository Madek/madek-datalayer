class Section < ApplicationRecord
  include Concerns::LocalizedFields

  belongs_to :keyword
  belongs_to :index_collection, class_name: "Collection", foreign_key: :index_collection_id 

  localize_fields :labels

end
