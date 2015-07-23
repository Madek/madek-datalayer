class MetaDatum::Users < MetaDatum

  has_many :meta_data_users,
           class_name: 'MetaDatum::User',
           foreign_key: :meta_datum_id

  has_many :users,
           through: :meta_data_users

  def to_s
    value.map(&:to_s).join('; ')
  end

  alias_method :value, :users

  def set_value!(users, created_by_user)
    reset_with_sanitized_value!(users, 'user', created_by_user)
  end

end
