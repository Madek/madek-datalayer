module Concerns
  module MediaResources
    module Filters
      module MetaKeys
        extend ActiveSupport::Concern
        included do
          scope :filter_by_meta_key, lambda { |meta_key_id|
            joins(:meta_data)
              .where(meta_data: { meta_key_id: meta_key_id })
          }

          scope :filter_by_not_meta_key, lambda { |meta_key_id|
            joins('LEFT JOIN meta_data ' \
                  'ON meta_data.media_entry_id = media_entries.id')
              .where.not(meta_data: { meta_key_id: meta_key_id })
              .uniq
          }
        end
      end
    end
  end
end
