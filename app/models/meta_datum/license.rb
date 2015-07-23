class MetaDatum::License < ActiveRecord::Base

  self.table_name = :meta_data_licenses

  include Concerns::MetaData::CreatedBy

  belongs_to :meta_datum
  belongs_to :license, class_name: '::License'
end
