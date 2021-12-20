class MetaDatum::MediaEntry < MetaDatum::Text
  include Concerns::MetaData::CreatedBy

  belongs_to :other_media_entry, \
             -> { with_unpublished }, class_name: '::MediaEntry'

  def value
    self
  end

  def set_value!(new_value, _created_by_user = nil)
    self.value = new_value.first
    if !other_media_entry_id.present?
      destroy!
    else
      save!
    end
  end

  private

  def assign_value(val, attr)
    with_sanitized(val) do |val|
      self[attr] = val
    end
  end

  def extract_values(string)
    values = string.split(';')
    uuid = values.shift
    description = values.join(';')
    [uuid, description]
  end

  def value=(new_value)
    uuid, description = extract_values(new_value)
    # FIXME: use a DB constraint instead
    UUIDTools::UUID.parse(uuid) if uuid.present?
    assign_value(uuid, :other_media_entry_id)
    assign_value(description, :string)
  end
end
