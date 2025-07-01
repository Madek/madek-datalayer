class RolesList < ApplicationRecord

  # include FindResource
  include LocalizedFields

  localize_fields :labels

  belongs_to :creator, class_name: 'User'
  has_many :meta_keys
  has_and_belongs_to_many :roles, join_table: 'roles_lists_roles'

  validate do
    errors.add(:base, "Label can't be blank") if label.blank?
  end

  scope :sorted, lambda { |locale = AppSetting.default_locale|
    throw unless AppSetting.available_locales.include?(locale.to_s)
    order(Arel.sql("roles_lists.labels->'#{locale}'"))
  }

  def self.filter_by(term = nil, meta_key_id = nil)
    roles_lists = all

    # if meta_key_id
    #   roles_lists = RolesList.where('roles.meta_key_id = ?', meta_key_id)
    # end

    return roles_lists if term.nil?

    if valid_uuid?(term)
      roles_lists = roles_lists.where(id: term)
    else
      roles_lists =
        roles_lists
        .where("array_to_string(avals(roles_lists.labels), '||') ILIKE ?",
               "%#{term}%")
    end

    roles_lists
  end

  def to_s
    label
  end
end
