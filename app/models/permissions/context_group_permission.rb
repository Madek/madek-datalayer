module Permissions
  class ContextGroupPermission < ApplicationRecord
    BASE_ENTITY_TABLE_NAME = 'contexts'

    include ::Permissions::Modules::Context
    include ::Permissions::Modules::GroupPermissionExistsConditions

    belongs_to :group
  end
end
