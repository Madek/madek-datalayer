class MetaDatum::Person < ApplicationRecord

  self.table_name = :meta_data_people

  include Concerns::MetaData::CreatedBy

  belongs_to :meta_datum
  belongs_to :person, class_name: '::Person'
end
