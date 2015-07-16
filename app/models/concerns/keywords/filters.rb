module Concerns
  module Keywords
    module Filters
      extend ActiveSupport::Concern

      included do
        scope :filter_by, lambda { |term|
          if UUIDTools::UUID_REGEXP =~ term
            where(id: term)
          else
            joins(:meta_key)
              .where(
                'keywords.term ILIKE :t OR meta_keys.id ILIKE :t',
                t: "%#{term}%"
              )
          end
        }
      end
    end
  end
end
