class MetaDatum::Licenses < MetaDatum

  has_many :meta_data_licenses,
           class_name: 'MetaDatum::License',
           foreign_key: :meta_datum_id

  has_many :licenses,
           through: :meta_data_licenses

  alias_method :value, :licenses

  def potential_value_for_new_record
    meta_data_licenses.map(&:license)
  end

  def set_value!(licenses, created_by_user)
    reset_with_sanitized_value!(licenses, 'license', created_by_user)
  end

end
