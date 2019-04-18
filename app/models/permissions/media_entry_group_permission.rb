module Permissions
  class MediaEntryGroupPermission < ApplicationRecord
    BASE_ENTITY_TABLE_NAME = 'media_entries'

    include ::Permissions::Modules::MediaEntry
    include ::Permissions::Modules::GroupPermissionExistsConditions

    belongs_to :group

    define_destroy_ineffective(
      [{ get_metadata_and_previews: false,
         get_full_size: false, edit_metadata: false }])
  end
end
