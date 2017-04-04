module Concerns
  module MediaResources
    module Filters
      module MetaData
        module Actors
          extend ActiveSupport::Concern

          include Concerns::MediaResources::Filters::MetaData::Helpers

          included do
            [:person, :keyword].each do |actor_type|
              method_name = "filter_by_meta_datum_#{actor_type.to_s.pluralize}"
              scope method_name,
                    lambda { |meta_datum|
                      filter_by_meta_datum_actor_type(actor_type, meta_datum)
                    }
            end
          end
        end
      end
    end
  end
end
