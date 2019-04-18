module Permissions
  class FilterSetUserPermission < ApplicationRecord
    include ::Permissions::Modules::FilterSet
    include ::Permissions::Modules::ArelConditions

    belongs_to :user

    define_destroy_ineffective(
      [{ get_metadata_and_previews: false,
         edit_metadata_and_filter: false,
         edit_permissions: false }]) do
           joins(:filter_set).where("filter_sets.responsible_user_id \
              = filter_set_user_permissions.user_id").delete_all
         end

    #################### AREL #########################

    define_user_permission_exists_condition('filter_sets')
  end
end
