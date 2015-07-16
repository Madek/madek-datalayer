class MetaDatum::Keywords < MetaDatum

  has_and_belongs_to_many :keywords,
                          class_name: '::Keyword',
                          join_table: :meta_data_keywords,
                          foreign_key: :meta_datum_id,
                          association_foreign_key: :keyword_id

  has_and_belongs_to_many :users,
                          join_table: :meta_data_keywords,
                          foreign_key: :meta_datum_id,
                          association_foreign_key: :user_id

  def to_s
    value.map(&:to_s).join('; ')
  end

  alias_method :value, :keywords

  def value=(keywords)
    with_sanitized keywords do |keywords|
      self.keywords.clear
      self.keywords = keywords
    end
  end
end
