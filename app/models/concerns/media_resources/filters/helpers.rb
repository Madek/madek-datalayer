module Concerns
  module MediaResources
    module Filters
      module Helpers
        extend ActiveSupport::Concern

        include Concerns::QueryHelpers
        include Concerns::MediaResources::Filters::MetaDataTypes
        include Concerns::MediaResources::Filters::MetaKeys

        module ClassMethods
          def filter_by_meta_datum(meta_datum)
            if meta_datum[:not_key]
              filter_by_not_meta_key meta_datum[:not_key]
            elsif meta_datum[:key] == 'any'
              filter_by_any_meta_key meta_datum
            elsif meta_datum[:match].nil? and meta_datum[:value].nil?
              filter_by_meta_key(meta_datum[:key])
            else
              filter_by_meta_key(meta_datum[:key])
                .filter_by_meta_datum_type \
                  Concerns::MetaData::FilterHelpers.with_type(meta_datum)
            end
          end

          def filter_by_any_meta_key(meta_datum)
            if meta_datum[:type].blank?
              filter_in_all_meta_data(meta_datum)
            else
              joins(:meta_data)
                .filter_by_meta_datum_type \
                  Concerns::MetaData::FilterHelpers.with_type(meta_datum)
            end
          end

          def filter_in_all_meta_data(meta_datum)
            query_strings = \
              ['MetaDatum::Text',
               'MetaDatum::TextDate',
               'MetaDatum::Keywords',
               'MetaDatum::People',
               'MetaDatum::Groups',
               'MetaDatum::Licenses'].map do |md_type|
                joins(:meta_data)
                  .filter_by_meta_datum_type(meta_datum.merge type: md_type)
                  .to_sql
              end

            from \
              join_query_strings_with_union \
                *query_strings
          end
        end
      end
    end
  end
end
