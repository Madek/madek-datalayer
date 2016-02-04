module Concerns
  module Entrust
    extend ActiveSupport::Concern
    include Concerns::AccessHelpers

    included do
      define_access_methods(:entrusted_to, self::VIEW_PERMISSION_NAME) do |user|
        user_permission_exists_condition(self::VIEW_PERMISSION_NAME, user).or(
          group_permission_for_user_exists_condition(self::VIEW_PERMISSION_NAME,
                                                     user))
      end
    end
  end
end
