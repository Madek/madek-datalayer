module Concerns
  module MediaResources
    module Filters
      module MetaDataTypes
        extend ActiveSupport::Concern

        include Concerns::MediaResources::Filters::MetaData::Actors
        include Concerns::MediaResources::Filters::MetaData::Primitive

        included do
          scope :filter_by_meta_datum_type, lambda { |value, type|
            # Example: MetaDatum::People -> filter_by_meta_datum_people
            filter_method = "filter_by_#{type.delete('::').underscore}".to_sym
            send(filter_method, value)
          }
        end
      end
    end
  end
end
