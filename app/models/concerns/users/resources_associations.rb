module Users
  module ResourcesAssociations
    extend ActiveSupport::Concern
    include Users::Resources::EntrustedResources
    include Users::Resources::FavoriteResources
    include Users::Resources::ResponsibleResources
  end
end
