module Concerns
  module Users
    module Keywords
      extend ActiveSupport::Concern

      included do
        has_many :keywords, foreign_key: :creator_id

        def used_keywords
          Keyword
            .select('keywords.*', 'meta_data_keywords.created_at')
            .joins('INNER JOIN meta_data_keywords ' \
                   'ON meta_data_keywords.keyword_id = keywords.id')
            .where(meta_data_keywords: { created_by_id: id })
            .reorder('meta_data_keywords.created_at DESC')
            .uniq
        end
      end
    end
  end
end
