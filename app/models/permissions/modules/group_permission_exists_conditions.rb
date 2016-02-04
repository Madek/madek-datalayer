module Permissions
  module Modules
    module GroupPermissionExistsConditions
      extend ActiveSupport::Concern
      include ::Permissions::Modules::ArelConditions

      included do
        define_group_permission_for_user_exists_condition \
          self::BASE_ENTITY_TABLE_NAME
        define_group_permission_exists_condition self::BASE_ENTITY_TABLE_NAME
      end
    end
  end
end
