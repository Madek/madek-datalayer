class MetaDatum::Keyword < ApplicationRecord
  include Orderable

  self.table_name = :meta_data_keywords

  include MetaData::CreatedBy

  belongs_to :meta_datum
  belongs_to :keyword, class_name: '::Keyword'

  enable_ordering skip_default_scope: true, parent_scope: :meta_datum, parent_child_relation: :meta_data_keywords

  before_create do
    keyword.update!(creator: created_by) unless keyword.creator.present?
  end
end
