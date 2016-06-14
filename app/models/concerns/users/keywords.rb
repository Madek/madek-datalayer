module Concerns
  module Users
    module Keywords
      extend ActiveSupport::Concern

      included do
        has_many :keywords, foreign_key: :creator_id

        def used_keywords
          Keyword.with_usage_count
            .where('meta_data_keywords.created_by_id = ?', id)
        end
      end
    end
  end
end
