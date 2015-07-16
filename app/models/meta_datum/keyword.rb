class MetaDatum::Keyword < ActiveRecord::Base
  self.table_name = :meta_data_keywords

  belongs_to :user
  belongs_to :meta_datum
  belongs_to :keyword, class_name: '::Keyword'

  before_create do
    keyword.update!(creator: user) unless keyword.creator.present?
  end
end
