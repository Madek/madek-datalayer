module Concerns
  module Keywords
    module Filters
      extend ActiveSupport::Concern

      included do
        scope :filter_by, lambda { |meta_key_id, term = nil, used_by_id = nil|
          if UUIDTools::UUID_REGEXP =~ term
            where(id: term)
          else
            keywords = Keyword.all

            if meta_key_id
              keywords.where(meta_key_id: meta_key_id)
            end

            if term
              keywords = keywords.where('keywords.term ILIKE :t', t: "%#{term}%")
            end

            if used_by_id
              keywords = \
                keywords
                  .select('keywords.*', 'meta_data_keywords.created_at')
                  .joins('INNER JOIN meta_data_keywords ' \
                         'ON meta_data_keywords.keyword_id = keywords.id')
                  .where(meta_data_keywords: { created_by_id: used_by_id })
                  .reorder('meta_data_keywords.created_at DESC')
                  .uniq
            end

            keywords
          end
        }
      end
    end
  end
end
