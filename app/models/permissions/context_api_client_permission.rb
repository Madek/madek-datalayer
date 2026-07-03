module Permissions
  class ContextApiClientPermission < ApplicationRecord
    include ::Permissions::Modules::Context
    belongs_to :api_client
  end
end
