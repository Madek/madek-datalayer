module Concerns
  module Keywords
    module Filters
      extend ActiveSupport::Concern

      included do
        def self.uniq_last_used_by(user_id)
          # NOTE: this is a helper method to get a subquery used in other methods.
          # Used in a standalone manner might result in something unexpected.
          select('keywords.*, max(meta_data_keywords.created_at) AS last_used_at')
            .joins('INNER JOIN meta_data_keywords ' \
                   'ON meta_data_keywords.keyword_id = keywords.id')
            .where('meta_data_keywords.created_by_id = ?', user_id)
            .group('keywords.id')
            .as('keywords')
        end

        def self.filter_by(meta_key_id = nil, term = nil, used_by_id = nil)
          keywords = Keyword.all

          if meta_key_id
            keywords = Keyword.where('keywords.meta_key_id = ?', meta_key_id)
          end

          if term
            if UUIDTools::UUID_REGEXP =~ term
              keywords = keywords.where(id: term)
            else
              keywords = keywords.where('keywords.term ILIKE :t', t: "%#{term}%")
            end
          end

          if used_by_id
            keywords = \
              keywords
                .from(uniq_last_used_by used_by_id)
                .order('keywords.last_used_at DESC')
          end

          keywords
        end

        def self.of_vocabulary(vocabulary_id)
          joins(:meta_key).where(meta_keys: { vocabulary_id: vocabulary_id })
        end

        def self.not_used
          all_with_usage_count
            .having('COUNT(meta_data_keywords.id) = ?', 0)
        end
      end
    end
  end
end
