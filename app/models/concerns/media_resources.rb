module MediaResources
  extend ActiveSupport::Concern

  include Entrust
  include MediaResources::CustomUrls
  include MediaResources::EditSessions
  include MediaResources::Favoritable
  include MediaResources::Filters::Filters
  include MediaResources::MetaData
  include MediaResources::PermissionsAssociations
  include MediaResources::Visibility
  include Users::Creator
  include Users::Responsible
end
