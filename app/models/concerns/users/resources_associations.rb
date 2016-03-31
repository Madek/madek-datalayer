module Concerns
  module Users
    module ResourcesAssociations
      extend ActiveSupport::Concern
      include Concerns::Users::Resources::EntrustedResources
      include Concerns::Users::Resources::FavoriteResources
      include Concerns::Users::Resources::ResponsibleResources
    end
  end
end
