module Concerns
  module Users
    module Keywords
      extend ActiveSupport::Concern

      included do
        has_many :keywords, foreign_key: :creator_id

        def used_keywords
          Keyword
            .select('keywords.*, count(keywords.id) AS usage_count')
            .joins('INNER JOIN meta_data_keywords ' \
                   'ON meta_data_keywords.keyword_id = keywords.id')
            .where('meta_data_keywords.created_by_id = ?', id)
            .group('keywords.id')
            .order('usage_count DESC')
        end
      end
    end
  end
end
