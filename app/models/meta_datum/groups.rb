class MetaDatum::Groups < MetaDatum

  has_many :meta_data_groups,
           class_name: 'MetaDatum::Group',
           foreign_key: :meta_datum_id

  has_many :groups,
           through: :meta_data_groups

  alias_method :value, :groups

  def set_value!(groups, created_by_user)
    reset_with_sanitized_value!(groups, 'group', created_by_user)
  end

end
