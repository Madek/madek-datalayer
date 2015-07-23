class MetaDatum::Group < ActiveRecord::Base

  self.table_name = :meta_data_groups

  include Concerns::MetaData::CreatedBy

  belongs_to :meta_datum
  belongs_to :group, class_name: '::Group'
end
