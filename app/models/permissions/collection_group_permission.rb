module Permissions
  class CollectionGroupPermission < ActiveRecord::Base
    include ::Permissions::Modules::Collection
    include ::Permissions::Modules::ArelConditions

    belongs_to :group

    #################### AREL #########################

    define_group_permission_for_user_exists_condition('collections')
  end
end
