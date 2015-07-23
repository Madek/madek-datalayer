class MetaDatum::People < MetaDatum

  has_many :meta_data_people,
           class_name: 'MetaDatum::Person',
           foreign_key: :meta_datum_id

  has_many :people,
           through: :meta_data_people

  def to_s
    value.map(&:to_s).join('; ')
  end

  alias_method :value, :people

  def set_value!(people, created_by_user)
    reset_with_sanitized_value!(people, 'person', created_by_user)
  end

end
