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
              filter_by_not_meta_key(meta_datum[:not_key], meta_datum[:md_alias])
            elsif meta_datum[:key] == 'any'
              filter_by_any_meta_key(meta_datum)
            elsif meta_datum[:match].nil? and meta_datum[:value].nil?
              filter_by_meta_key(meta_datum[:key], meta_datum[:md_alias])
            else
              filter_by_meta_key(meta_datum[:key], meta_datum[:md_alias])
                .filter_by_meta_datum_type \
                  Concerns::MetaData::FilterHelpers.with_type(meta_datum)
            end
          end

          def filter_by_any_meta_key(meta_datum)
            if meta_datum[:type].blank?
              search_in_all_meta_data meta_datum[:match]
            else
              joins("INNER JOIN meta_data #{meta_datum[:md_alias]} " \
                    "ON #{meta_datum[:md_alias] or 'meta_data'}" \
                    ".#{model_name.singular}_id = #{model_name.plural}.id")
                .filter_by_meta_datum_type \
                  Concerns::MetaData::FilterHelpers.with_type(meta_datum)
            end
          end

          def search_in_all_meta_data(match)
            where \
              matching_meta_data_exists_condition(match)
                .or(matching_meta_data_keywords_exists_conditition(match))
                .or(matching_meta_data_licenses_exists_conditition(match))
                .or(matching_meta_data_people_exists_conditition(match))
                .or(matching_meta_data_groups_exists_conditition(match))
          end
        end
      end
    end
  end
end
