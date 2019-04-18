module Permissions
  class CollectionApiClientPermission < ApplicationRecord
    include ::Permissions::Modules::Collection
    belongs_to :api_client
  end
end
