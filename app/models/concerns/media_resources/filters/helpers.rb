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
              filter_by_not_meta_key(meta_datum[:not_key],
                                     meta_datum[:meta_keys_scope])
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
            meta_key_ids = meta_datum[:meta_keys_scope].map(&:id)

            if meta_datum[:type].blank?
              search_in_all_meta_data meta_datum[:match], meta_key_ids
            else
              md_table_name = (meta_datum[:md_alias] or 'meta_data')

              joins("INNER JOIN meta_data #{meta_datum[:md_alias]} " \
                    "ON #{md_table_name}" \
                    ".#{model_name.singular}_id = #{model_name.plural}.id")
                .where(Hash[md_table_name, { meta_key_id: meta_key_ids }])
                .filter_by_meta_datum_type \
                  Concerns::MetaData::FilterHelpers.with_type(meta_datum)
            end
          end

          def search_in_all_meta_data(match, meta_key_ids)
            where \
              matching_meta_data_exists_condition(match, meta_key_ids)
                .or(matching_meta_data_keywords_exists_conditition(match,
                                                                   meta_key_ids))
                .or(matching_meta_data_people_exists_conditition(match,
                                                                 meta_key_ids))
                .or(matching_meta_data_roles_roles_exists_condition(match,
                                                                    meta_key_ids))
                .or(matching_meta_data_roles_people_exists_condition(match,
                                                                     meta_key_ids))
          end
        end
      end
    end
  end
end
