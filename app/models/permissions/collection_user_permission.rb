module Permissions
  class CollectionUserPermission < ApplicationRecord
    include ::Permissions::Modules::Collection
    include ::Permissions::Modules::ArelConditions

    belongs_to :user

    define_destroy_ineffective(
      [{ get_metadata_and_previews: false,
         edit_metadata_and_relations: false }]) do
        joins(:collection).where(
          "collections.responsible_user_id \
          = collection_user_permissions.user_id").delete_all
    end

    #################### AREL #########################

    define_user_permission_exists_condition('collections')
  end
end
