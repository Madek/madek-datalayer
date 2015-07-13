module Concerns
  module IoMappings
    module Filters
      extend ActiveSupport::Concern

      included do
        scope :filter_by, lambda { |term|
          where(
            'io_mappings.meta_key_id ILIKE :t OR io_mappings.key_map ILIKE :t',
            t: "%#{term}%"
          )
        }
      end
    end
  end
end
