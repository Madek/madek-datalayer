module Permissions
  class VocabularyApiClientPermission < ApplicationRecord
    include ::Permissions::Modules::Vocabulary
    belongs_to :api_client
  end
end
