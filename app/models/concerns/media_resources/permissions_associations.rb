module Concerns
  module MediaResources
    module PermissionsAssociations
      extend ActiveSupport::Concern
      include Concerns::PermissionsAssociations

      def public_view?
        get_metadata_and_previews
      end

      module ClassMethods
        def user_permission_exists_condition(perm_type, user)
          "Permissions::#{name}UserPermission".constantize
            .user_permission_exists_condition(perm_type, user)
        end

        def group_permission_exists_condition(perm_type, group)
          "Permissions::#{name}GroupPermission".constantize
            .user_permission_exists_condition(perm_type, group)
        end

        def group_permission_for_user_exists_condition(perm_type, user)
          "Permissions::#{name}GroupPermission".constantize
            .group_permission_for_user_exists_condition(perm_type, user)
        end
      end
    end
  end
end
