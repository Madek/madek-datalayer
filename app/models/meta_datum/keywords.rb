class MetaDatum::Keywords < MetaDatum

  has_many :meta_data_keywords,
           class_name: 'MetaDatum::Keyword',
           foreign_key: :meta_datum_id

  has_many :keywords,
           through: :meta_data_keywords

  def to_s
    value.map(&:to_s).join('; ')
  end

  alias_method :value, :keywords

  def set_value!(keywords, created_by_user)
    reset_with_sanitized_value!(keywords, 'keyword', created_by_user)
  end

end
