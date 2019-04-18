module Permissions
  class FilterSetApiClientPermission < ApplicationRecord
    include ::Permissions::Modules::FilterSet
    belongs_to :api_client
  end
end
