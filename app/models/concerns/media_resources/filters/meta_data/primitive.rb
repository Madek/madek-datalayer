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

                      sanitized = sanitize_sql_for_conditions(
                        [
                          "AND to_tsvector('english', " \
                          "#{meta_datum[:md_alias] or 'meta_data'}.string) " \
                          '@@ ' \
                          "plainto_tsquery('english', '%s')",
                          meta_datum[:match]
                        ]
                      )

                      joins(sanitized)
                    }
            end
          end
        end
      end
    end
  end
end
