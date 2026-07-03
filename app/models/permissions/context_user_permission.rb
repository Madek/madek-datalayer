module Permissions
  class ContextUserPermission < ApplicationRecord
    include ::Permissions::Modules::Context
    include ::Permissions::Modules::ArelConditions
    belongs_to :user

    define_user_permission_exists_condition('contexts')
  end
end
