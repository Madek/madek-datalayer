class Delegation < ApplicationRecord
  include BetaTesting
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
  has_and_belongs_to_many :workflows
  has_many :media_entries, foreign_key: :responsible_delegation_id
  has_many :collections, foreign_key: :responsible_delegation_id

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
    select('delegations.*, '\
      '(COUNT(DISTINCT delegations_users.user_id) + COUNT(DISTINCT groups_users.user_id)) '\
      'AS members_count, COUNT(DISTINCT groups_users.user_id) as group_members_count')
      .joins('LEFT OUTER JOIN delegations_users '\
             'ON delegations_users.delegation_id = delegations.id')
      .joins('LEFT OUTER JOIN delegations_groups '\
             'ON delegations_groups.delegation_id = delegations.id')
      .joins('LEFT OUTER JOIN groups_users '\
             'ON delegations_groups.group_id = groups_users.group_id')
      .group('delegations.id')
  end

  def self.with_resources_count
    select('delegations.*, '\
      '(COUNT(DISTINCT media_entries.id) + COUNT(DISTINCT collections.id)) AS resources_count')
      .joins('LEFT OUTER JOIN media_entries '\
             'ON media_entries.responsible_delegation_id = delegations.id')
      .joins('LEFT OUTER JOIN collections ON '\
             'collections.responsible_delegation_id = delegations.id')
      .group('delegations.id')
  end

  def self.filter_by(term, group_or_user_id = nil)
    result = current_scope

    if term.present?
      result = result.where('delegations.name ILIKE ?', "%#{term}%")
    end

    if group_or_user_id.present? && valid_uuid?(group_or_user_id)
      result = result
        .joins(:users, :groups)
        .where('users.id = :id OR groups.id = :id', id: group_or_user_id)
    end

    result
  end

  def to_s
    name
  end
end
