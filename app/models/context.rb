class Context < ApplicationRecord
  VIEW_PERMISSION_NAME = :view

  include Entrust
  include PermissionsAssociations
  include Contexts::AccessScopesAndHelpers
  include LocalizedFields

  has_many(:context_keys,
           -> { order('context_keys.position ASC') },
           foreign_key: :context_id, dependent: :destroy)

  localize_fields :labels, :descriptions

  def to_s
    id
  end

  def self.user_permission_exists_condition(perm_type, user)
    Permissions::ContextUserPermission.user_permission_exists_condition(perm_type, user)
  end

  def self.group_permission_exists_condition(perm_type, group)
    Permissions::ContextGroupPermission.user_permission_exists_condition(perm_type, group)
  end

  def self.group_permission_for_user_exists_condition(perm_type, user)
    Permissions::ContextGroupPermission.group_permission_for_user_exists_condition(perm_type, user)
  end
end
