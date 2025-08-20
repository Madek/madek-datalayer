class Role < ApplicationRecord

  include Roles::Filters
  include FindResource
  include LocalizedFields

  localize_fields :labels

  belongs_to :creator, class_name: 'User'
  has_and_belongs_to_many :roles_lists, join_table: 'roles_lists_roles'
  has_many :meta_data_people, class_name: 'MetaDatum::Person', dependent: :nullify
  has_many :meta_data, through: :meta_data_people

  scope :sorted, lambda { |locale = AppSetting.default_locale|
    throw unless AppSetting.available_locales.include?(locale.to_s)
    order(Arel.sql("roles.labels->'#{locale}'"))
  }
  scope :with_usage_count, lambda {
    select('roles.*, count(meta_data_people.id) as usage_count')
      .joins('LEFT OUTER JOIN meta_data_people' \
             ' ON meta_data_people.role_id = roles.id')
      .group('roles.id')
  }

  validate do
    errors.add(:base, "Label can't be blank") if label.blank?
  end

  def to_s
    label
  end

  def usage_count
    meta_data_people.count
  end
end
