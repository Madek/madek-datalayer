module Concerns
  module MediaResources
    module Filters
      module MetaKeys
        extend ActiveSupport::Concern
        included do
          scope :filter_by_meta_key, lambda { |meta_key_id, md_alias = nil|
            joins("INNER JOIN meta_data #{md_alias} " \
                  "ON #{md_alias or 'meta_data'}.#{model_name.singular}_id " \
                  "= #{model_name.plural}.id " \
                  "AND #{md_alias or 'meta_data'}.meta_key_id = '#{meta_key_id}'")
          }

          scope :filter_by_not_meta_key, lambda { |meta_key_id, meta_keys_scope|
            meta_key_ids = meta_keys_scope.map(&:id)
            meta_key_ids -= [meta_key_id]
            meta_data = MetaDatum.arel_table
            where \
              meta_data
                .where(meta_data["#{model_name.singular}_id"].eq arel_table[:id])
                .where(meta_data[:meta_key_id].in meta_key_ids)
                .project(1)
                .exists
          }
        end
      end
    end
  end
end
