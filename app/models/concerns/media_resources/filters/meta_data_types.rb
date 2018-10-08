module Concerns
  module MediaResources
    module Filters
      module MetaDataTypes
        extend ActiveSupport::Concern

        include Concerns::MediaResources::Filters::MetaData::Actors
        include Concerns::MediaResources::Filters::MetaData::Primitive
        include Concerns::MediaResources::Filters::MetaData::Roles

        included do
          scope :filter_by_meta_datum_type, lambda { |meta_datum|
            # Example: MetaDatum::People -> filter_by_meta_datum_people
            filter_method = \
              "filter_by_#{meta_datum[:type].delete('::').underscore}"
                .to_sym
            send(filter_method, meta_datum)
          }
        end
      end
    end
  end
end
