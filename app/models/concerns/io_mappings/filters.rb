module IoMappings
  module Filters
    extend ActiveSupport::Concern

    included do
      scope :filter_by, lambda { |term|
        left_joins(xmp_property: :xmp_namespace).where(
          'io_mappings.meta_key_id ILIKE :t OR io_mappings.key_map ILIKE :t ' \
          "OR xmp_namespaces.prefix || ':' || xmp_properties.name ILIKE :t",
          t: "%#{term}%"
        )
      }
    end
  end
end
