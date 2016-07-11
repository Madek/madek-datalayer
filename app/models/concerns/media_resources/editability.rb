module Concerns
  module MediaResources
    module Editability
      extend ActiveSupport::Concern
      include Concerns::AccessHelpers

      included do
        define_access_methods(:editable_by, self::EDIT_PERMISSION_NAME) do |user|
          user_permission_exists_condition(self::EDIT_PERMISSION_NAME, user)
            .or(group_permission_for_user_exists_condition(
                  self::EDIT_PERMISSION_NAME, user))
            .or(arel_table[:responsible_user_id].eq user.id)
        end
        define_access_methods(:manageable_by, self::MANAGE_PERMISSION_NAME) do |u|
          user_permission_exists_condition(self::MANAGE_PERMISSION_NAME, u)
            .or(arel_table[:responsible_user_id].eq u.id)
        end
      end
    end
  end
end
