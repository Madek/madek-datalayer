module Concerns
  module MediaResources
    module Filters
      module MetaData
        module Primitive
          extend ActiveSupport::Concern

          included do
            %w(text text_date).each do |primitive_type|
              method_name = "filter_by_meta_datum_#{primitive_type}".to_sym
              scope method_name,
                    lambda { |meta_datum|
                      Concerns::MetaData::FilterHelpers
                        .validate_keys_for_primitive!(meta_datum)
                      where("string ILIKE '%#{meta_datum[:match]}%'")
                    }
            end
          end
        end
      end
    end
  end
end
