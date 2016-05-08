class FilterSet < ActiveRecord::Base

  VIEW_PERMISSION_NAME = :get_metadata_and_previews

  include Concerns::MediaResources
  include Concerns::MediaResources::Highlight
  include Concerns::MediaResources::MetaDataArelConditions

  # NOTE: could possibly be made as a DB trigger
  # NOTE: disabled because there is no workflow yet
  # validate :validate_existence_of_meta_data_for_required_context_keys
end
