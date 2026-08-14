class Delegation < ApplicationRecord
  include Delegations::Notifications

  #############################################################################

  before_destroy do
    if all_associated_media_entries.deleted.exists? \
        or all_associated_collections.deleted.exists?

      errors.add(
        :base,
        "Cannot delete a delegation with associated soft-deleted media resources."
      )
      throw(:abort)
    end
  end

  #############################################################################

  has_and_belongs_to_many :groups
  has_and_belongs_to_many :users
  has_and_belongs_to_many(:supervisors,
                          class_name: 'User',
                          join_table: :delegations_supervisors)
  has_many :media_entries, foreign_key: :responsible_delegation_id
  has_many :collections, foreign_key: :responsible_delegation_id
  has_many :emails

  validates :name, presence: true, uniqueness: true
  validates(:notifications_email, allow_nil: true,
            format: { with: URI::MailTo::EMAIL_REGEXP })

  #############################################################################

  def all_associated_media_entries
    MediaEntry.unscoped.where(responsible_delegation_id: self.id)
  end

  def all_associated_collections
    Collection.unscoped.where(responsible_delegation_id: self.id)
  end

  #############################################################################

  def self.apply_sorting(sorting)
    if allowed_sortings.key?(sorting&.to_sym)
      current_scope.order(allowed_sortings[sorting.to_sym])
    else
      current_scope.order(allowed_sortings[:name])
    end
  end

  def self.allowed_sortings
    {
      name: 'name ASC',
      members_count: 'members_count DESC',
      resources_count: 'resources_count DESC'
    }
  end

  def self.with_members_count
    group_members_sql = <<~SQL.squish
      SELECT COUNT(DISTINCT groups_users.user_id)
      FROM delegations_groups
      INNER JOIN groups_users ON groups_users.group_id = delegations_groups.group_id
      WHERE delegations_groups.delegation_id = delegations.id
    SQL

    select(<<~SQL.squish)
      delegations.*,
      (
        (SELECT COUNT(*)
         FROM delegations_users
         WHERE delegations_users.delegation_id = delegations.id)
        +
        (#{group_members_sql})
      ) AS members_count,
      (#{group_members_sql}) AS group_members_count
    SQL
  end

  def self.with_resources_count
    select(<<~SQL.squish)
      delegations.*,
      (
        (SELECT COUNT(*) FROM media_entries
         WHERE media_entries.responsible_delegation_id = delegations.id)
        +
        (SELECT COUNT(*) FROM collections
         WHERE collections.responsible_delegation_id = delegations.id)
      ) AS resources_count
    SQL
  end

  def self.filter_by(term, group_or_user_id = nil)
    result = current_scope

    if term.present?
      result = result.where('delegations.name ILIKE ?', "%#{term}%")
    end

    if group_or_user_id.present? && valid_uuid?(group_or_user_id)
      result = result.where(<<~SQL.squish, id: group_or_user_id)
        EXISTS (
          SELECT 1 FROM delegations_users
          WHERE delegations_users.delegation_id = delegations.id
            AND delegations_users.user_id = :id
        )
        OR EXISTS (
          SELECT 1 FROM delegations_groups
          WHERE delegations_groups.delegation_id = delegations.id
            AND delegations_groups.group_id = :id
        )
      SQL
    end

    result
  end

  def to_s
    name
  end

end
