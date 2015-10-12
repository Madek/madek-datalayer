module Concerns
  module Keywords
    module Filters
      extend ActiveSupport::Concern

      included do
        scope :filter_by, lambda { |term, meta_key_id|
          if UUIDTools::UUID_REGEXP =~ term
            where(id: term)
          else
            keywords = all
            if meta_key_id
              keywords = \
                keywords.joins(:meta_key).where(meta_key_id: meta_key_id)
            end
            if term
              keywords = \
                keywords.where('keywords.term ILIKE :t', t: "%#{term}%")
            end
            keywords
          end
        }
      end
    end
  end
end
