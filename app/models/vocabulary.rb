class Vocabulary < ApplicationRecord

  VIEW_PERMISSION_NAME = :view

  include Concerns::Entrust
  include Concerns::PermissionsAssociations
  include Concerns::Vocabularies::AccessScopesAndHelpers
  include Concerns::Vocabularies::Filters
  include Concerns::Orderable
  include Concerns::LocalizedFields

  enable_ordering
  localize_fields :labels, :descriptions

  has_many :meta_keys
  has_many :keywords,
           through: :meta_keys

  scope :sorted, lambda { |locale = AppSetting.default_locale|
    unscoped.order("vocabularies.labels->'#{locale}'")
  }
  scope :with_meta_keys_count, lambda {
    joins('LEFT OUTER JOIN meta_keys ON meta_keys.vocabulary_id = vocabularies.id')
      .select('vocabularies.*, count(meta_keys.id) AS meta_keys_count')
      .group('vocabularies.id')
  }

  validates :id, presence: true

  def to_s
    id
  end

  def self.user_permission_exists_condition(perm_type, user)
    Permissions::VocabularyUserPermission
      .user_permission_exists_condition(perm_type, user)
  end

  def self.group_permission_exists_condition(perm_type, group)
    Permissions::VocabularyGroupPermission
      .user_permission_exists_condition(perm_type, group)
  end

  def self.group_permission_for_user_exists_condition(perm_type, user)
    Permissions::VocabularyGroupPermission
      .group_permission_for_user_exists_condition(perm_type, user)
  end

  def can_have_keywords?
    !meta_keys.where(meta_datum_object_type: 'MetaDatum::Keywords').empty?
  end

  def can_have_roles?
    !meta_keys.where(meta_datum_object_type: 'MetaDatum::Roles').empty?
  end
end
