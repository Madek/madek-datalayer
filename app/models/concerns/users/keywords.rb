module Concerns
  module Users
    module Keywords
      extend ActiveSupport::Concern

      included do
        has_many :keywords, foreign_key: :creator_id

        has_and_belongs_to_many :used_keywords,
                                -> { uniq },
                                join_table: 'meta_data_keywords',
                                foreign_key: :created_by_id,
                                association_foreign_key: :keyword_id,
                                class_name: '::Keyword'

      end
    end
  end
end
