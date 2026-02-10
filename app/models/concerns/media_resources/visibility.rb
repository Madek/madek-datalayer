module MediaResources
  module Visibility
    extend ActiveSupport::Concern
    include AccessHelpers

    def viewable_by_public?
      get_metadata_and_previews?
    end

    included do
      define_access_methods(:viewable_by, self::VIEW_PERMISSION_NAME)
    end

    class_methods do
      def viewable_by_public
        where(Hash[self::VIEW_PERMISSION_NAME, true])
      end

      def viewable_by_user(user)
        conditions = arel_table[self::VIEW_PERMISSION_NAME].eq(true)
          .or(arel_table[:responsible_user_id].eq(user.id))
          .or(arel_table[:responsible_delegation_id].in(user.delegation_ids))
          .or("Permissions::#{name}UserPermission".constantize \
                .user_permission_exists_condition \
                  self::VIEW_PERMISSION_NAME, user)
          .or("Permissions::#{name}GroupPermission".constantize \
                .group_permission_for_user_exists_condition \
                  self::VIEW_PERMISSION_NAME, user)

        where(conditions)
      end

      def viewable_by_user_or_public(user = nil)
        if user
          viewable_by_user(user)
        else
          viewable_by_public
        end
      end
    end
  end
end
