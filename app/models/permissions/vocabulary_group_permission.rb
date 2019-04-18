module Permissions
  class VocabularyGroupPermission < ApplicationRecord
    BASE_ENTITY_TABLE_NAME = 'vocabularies'

    include ::Permissions::Modules::Vocabulary
    include ::Permissions::Modules::GroupPermissionExistsConditions

    belongs_to :group
  end
end
