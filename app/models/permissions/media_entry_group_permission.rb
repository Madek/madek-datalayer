module Permissions
  class MediaEntryGroupPermission < ActiveRecord::Base
    include ::Permissions::Modules::MediaEntry
    include ::Permissions::Modules::ArelConditions

    belongs_to :group

    define_destroy_ineffective(
      [{ get_metadata_and_previews: false,
         get_full_size: false, edit_metadata: false }])

    #################### AREL #########################

    define_group_permission_for_user_exists_condition('media_entries')
  end
end
