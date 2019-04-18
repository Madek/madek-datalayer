module Permissions
  class VocabularyUserPermission < ApplicationRecord
    include ::Permissions::Modules::Vocabulary
    include ::Permissions::Modules::ArelConditions
    belongs_to :user

    define_user_permission_exists_condition('vocabularies')
  end
end
