module Concerns
  module Users
    module Keywords
      extend ActiveSupport::Concern

      included do
        has_many :keywords, foreign_key: :creator_id

        def used_keywords
          Keyword.with_usage_count
            .joins('INNER JOIN meta_data_keywords ' \
                   'ON meta_data_keywords.keyword_id = keywords.id')
            .joins('INNER JOIN meta_data ' \
                   'ON meta_data.id = meta_data_keywords.meta_datum_id')
            .joins('LEFT JOIN media_entries ' \
                   'ON media_entries.id = meta_data.media_entry_id')
            .where('(meta_data.media_entry_id IS NOT NULL ' \
                    'AND media_entries.is_published) OR ' \
                    'meta_data.collection_id IS NOT NULL OR ' \
                    'meta_data.filter_set_id IS NOT NULL')
            .where('meta_data_keywords.created_by_id = ?', id)
        end
      end
    end
  end
end
