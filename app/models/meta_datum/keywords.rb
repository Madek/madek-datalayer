class MetaDatum::Keywords < MetaDatum

  ATTRIBUTES_FOR_ON_THE_FLY_RESOURCE_CREATION = [:term, :meta_key_id]

  has_many :meta_data_keywords,
           class_name: 'MetaDatum::Keyword',
           foreign_key: :meta_datum_id

  has_many :keywords,
    ->(parent) do
      mk = parent.meta_key || OpenStruct.new(selection_field_type: 'list', keywords: [], keywords_alphabetical_order: false)
      order(
        [
          *('meta_data_keywords.position ASC' if mk.selection_field_type == "list" || (mk.selection_field_type == "auto" && mk.keywords.count > 16)),
          mk.keywords_alphabetical_order ? :term : :position,
          :id
        ].compact
      )
    end,
    through: :meta_data_keywords

  def to_s
    value.map(&:to_s).join('; ')
  end

  alias_method :value, :keywords

  def potential_value_for_new_record
    meta_data_keywords.map(&:keyword)
  end

  def set_value!(keywords, created_by_user)
    reset_with_sanitized_value!(keywords, 'keyword', created_by_user)
  end

  def sanitize_attributes_for_on_the_fly_resource_creation(attrs_hash)
    permitted_hash = \
      attrs_hash.permit(ATTRIBUTES_FOR_ON_THE_FLY_RESOURCE_CREATION)
    permitted_hash.merge(meta_key_id: meta_key_id)
  end

end
