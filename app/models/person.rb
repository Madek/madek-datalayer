class Person < ApplicationRecord
  include FindResource
  include People::Filters
  include PreviousId

  self.inheritance_column = false

  default_scope { reorder(:last_name, :first_name, :id) }
  scope :subtypes, -> { unscoped.select(:subtype).distinct }

  has_one :user

  def meta_data
    MetaDatum
      .joins(<<-SQL)
        LEFT JOIN meta_data_people
        ON meta_data_people.meta_datum_id = meta_data.id
      SQL
      .joins(<<-SQL)
        LEFT JOIN meta_data_roles
        ON meta_data_roles.meta_datum_id = meta_data.id
      SQL
      .where("meta_data_people.person_id = :id OR meta_data_roles.person_id = :id",
             id: id)
  end

  def published_meta_data
    meta_data
      .joins(<<-SQL)
        LEFT JOIN media_entries
        ON media_entries.id = meta_data.media_entry_id
      SQL
      .where(<<-SQL)
        (media_entries.id IS NOT NULL AND media_entries.is_published)
        OR media_entries.id IS NULL
      SQL
  end

  has_many :meta_data_people, class_name: '::MetaDatum::Person'
  has_many :meta_data_roles, class_name: '::MetaDatum::Role'
  has_and_belongs_to_many :roles, join_table: :meta_data_roles

  validate do
    if [first_name, last_name, pseudonym].all?(&:blank?)
      errors.add(:base,
                 'Either first_name or last_name or pseudonym must have a value!')
    end
  end

  before_save :reject_blank_uris

  def to_s
    case
    when ((first_name or last_name) and (pseudonym and !pseudonym.try(:empty?)))
      "#{first_name} #{last_name} (#{pseudonym})".strip
    when (first_name or last_name)
      "#{first_name} #{last_name}".strip
    else
      pseudonym.strip
    end
  end

  def merge_to(receiver, creator_fallback = nil)
    ActiveRecord::Base.transaction do
      self.meta_data_people.each do |mdp|
        if mdp.meta_datum.meta_data_people.find_by(person_id: receiver.id)
          mdp.destroy!
        else 
          mdp.update_columns(
            person_id: receiver.id,
            created_by_id: (receiver.user.try(:id) || creator_fallback&.id)
          )
        end
      end

      self.meta_data_roles.each do |mdr|
        if mdr.meta_datum.meta_data_roles.find_by(person_id: receiver.id,
                                                  role_id: mdr.role_id)
          mdr.destroy!
        else 
          mdr.update_columns(person_id: receiver.id)
        end
      end

      user.update!(person: receiver) if user
      remember_previous_ids!(receiver)
      destroy!
    end
  end

  private

  def reject_blank_uris
    self.external_uris = external_uris&.reject(&:blank?)
  end
end
