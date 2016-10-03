class MetaDatum::People < MetaDatum

  ATTRIBUTES_FOR_ON_THE_FLY_RESOURCE_CREATION = [:first_name,
                                                 :last_name,
                                                 :pseudonym,
                                                 :subtype]

  has_many :meta_data_people,
           class_name: 'MetaDatum::Person',
           foreign_key: :meta_datum_id

  has_many :people,
           through: :meta_data_people

  def to_s
    value.map(&:to_s).join('; ')
  end

  alias_method :value, :people

  def potential_value_for_new_record
    meta_data_people.map(&:person)
  end

  def set_value!(people, created_by_user)
    reset_with_sanitized_value!(people, 'person', created_by_user)
  end

  def sanitize_attributes_for_on_the_fly_resource_creation(attrs_hash)
    attrs_hash.permit(ATTRIBUTES_FOR_ON_THE_FLY_RESOURCE_CREATION)
  end

end
