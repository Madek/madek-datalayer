class MetaDatum::User < ActiveRecord::Base

  self.table_name = :meta_data_users

  include Concerns::MetaData::CreatedBy

  belongs_to :meta_datum
  belongs_to :user, class_name: '::User'
end
