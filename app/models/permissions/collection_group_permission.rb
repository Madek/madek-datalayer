module Permissions
  class CollectionGroupPermission < ActiveRecord::Base
    BASE_ENTITY_TABLE_NAME = 'collections'

    include ::Permissions::Modules::Collection
    include ::Permissions::Modules::GroupPermissionExistsConditions

    belongs_to :group
  end
end
