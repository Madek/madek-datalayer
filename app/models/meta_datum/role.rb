class MetaDatum::Role < ApplicationRecord

  self.table_name = :meta_data_roles

  include Concerns::MetaData::CreatedBy

  belongs_to :meta_datum
  belongs_to :role, class_name: '::Role'
  belongs_to :person, class_name: '::Person'
end
