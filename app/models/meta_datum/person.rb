class MetaDatum::Person < ApplicationRecord
  include Orderable

  self.table_name = :meta_data_people

  include MetaData::CreatedBy

  belongs_to :meta_datum
  belongs_to :person, class_name: '::Person'

  enable_ordering skip_default_scope: true, parent_scope: :meta_datum, parent_child_relation: :meta_data_people
end
