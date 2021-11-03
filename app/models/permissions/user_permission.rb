class Permissions::UserPermission
  class << self
    def permitted_for?(perm_type, resource:, user:)
      case resource
      when MediaEntry
        Permissions::MediaEntryUserPermission
          .permitted_for?(perm_type, resource: resource, user: user)
      when Collection
        Permissions::CollectionUserPermission
          .permitted_for?(perm_type, resource: resource, user: user)
      else
        raise "Unsupported resource class: #{resource.class}"
      end
    end
  end
end
