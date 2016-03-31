module Concerns
  module Users
    module Resources
      module EntrustedResources
        def entrusted_media_entry_to_groups?(media_entry)
          responsible_media_entries
            .joins(:group_permissions)
            .where(media_entry_group_permissions:
              { media_entry_id: media_entry.id,
                get_metadata_and_previews: true })
            .exists?
        end

        def entrusted_media_entry_to_users?(media_entry)
          responsible_media_entries
            .joins(:user_permissions)
            .where(media_entry_user_permissions:
              { media_entry_id: media_entry.id,
                get_metadata_and_previews: true })
            .exists?
        end

        def entrusted_collection_to_groups?(collection)
          responsible_collections
            .joins(:group_permissions)
            .where(collection_group_permissions:
              { collection_id: collection.id,
                get_metadata_and_previews: true })
            .exists?
        end

        def entrusted_collection_to_users?(collection)
          responsible_collections
            .joins(:user_permissions)
            .where(collection_user_permissions:
              { collection_id: collection.id,
                get_metadata_and_previews: true })
            .exists?
        end

        def entrusted_filter_set_to_groups?(filter_set)
          responsible_filter_sets
            .joins(:group_permissions)
            .where(filter_set_group_permissions:
              { filter_set_id: filter_set.id,
                get_metadata_and_previews: true })
            .exists?
        end

        def entrusted_filter_set_to_users?(filter_set)
          responsible_filter_sets
            .joins(:user_permissions)
            .where(filter_set_user_permissions:
              { filter_set_id: filter_set.id,
                get_metadata_and_previews: true })
            .exists?
        end
      end
    end
  end
end
