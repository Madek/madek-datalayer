module Permissions
  class FilterSetGroupPermission < ApplicationRecord
    BASE_ENTITY_TABLE_NAME = 'filter_sets'

    include ::Permissions::Modules::FilterSet
    include ::Permissions::Modules::GroupPermissionExistsConditions

    belongs_to :group
  end
end
