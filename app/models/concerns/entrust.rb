module Entrust
  extend ActiveSupport::Concern
  include AccessHelpers

  included do
    define_access_methods(:entrusted_to, self::VIEW_PERMISSION_NAME) do |user, add_group_cond: nil|
      user_permission_exists_condition(self::VIEW_PERMISSION_NAME, user).or(
        group_permission_for_user_exists_condition(self::VIEW_PERMISSION_NAME,
                                                    user,
                                                    add_group_cond))
    end

    define_singleton_method :entrusted_to_api_client do |api_client|
      where(
        "Permissions::#{name}ApiClientPermission".constantize \
          .api_client_permission_exists_condition(self::VIEW_PERMISSION_NAME, api_client))
    end
  end
end
