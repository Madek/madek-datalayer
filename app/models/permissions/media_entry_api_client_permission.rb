module Permissions
  class MediaEntryApiClientPermission < ApplicationRecord
    include ::Permissions::Modules::MediaEntry
    include ::Permissions::Modules::ArelConditions

    belongs_to :api_client
    define_destroy_ineffective(
      [{ get_metadata_and_previews: false,
         get_full_size: false }])

    define_api_client_permission_exists_condition('media_entries')
  end
end
