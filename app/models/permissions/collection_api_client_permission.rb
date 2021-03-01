module Permissions
  class CollectionApiClientPermission < ApplicationRecord
    include ::Permissions::Modules::Collection
    include ::Permissions::Modules::ArelConditions

    belongs_to :api_client

    define_api_client_permission_exists_condition('collections')
  end
end
