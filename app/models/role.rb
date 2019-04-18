class Role < ApplicationRecord

  include Concerns::Roles::Filters
  include Concerns::FindResource
  include Concerns::LocalizedFields

  localize_fields :labels

  belongs_to :creator, class_name: 'User'
  belongs_to :meta_key
  has_many :meta_data_roles, class_name: 'MetaDatum::Role', dependent: :nullify
  has_many :meta_data, through: :meta_data_roles

  scope :sorted, lambda { |locale = AppSetting.default_locale|
    order("roles.labels->'#{locale}'")
  }
  scope :with_usage_count, lambda {
    select('roles.*, count(meta_data_roles.id) as usage_count')
      .joins('LEFT OUTER JOIN meta_data_roles' \
             'ON meta_data_roles.role_id = roles.id')
      .group('roles.id')
  }

  validate do
    errors.add(:base, "Label can't be blank") if label.blank?
  end

  def to_s
    label
  end

  def usage_count
    meta_data.count
  end
end
