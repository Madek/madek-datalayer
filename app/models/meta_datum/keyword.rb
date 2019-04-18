class MetaDatum::Keyword < ApplicationRecord

  self.table_name = :meta_data_keywords

  include Concerns::MetaData::CreatedBy

  belongs_to :meta_datum
  belongs_to :keyword, class_name: '::Keyword'

  before_create do
    keyword.update!(creator: created_by) unless keyword.creator.present?
  end
end
