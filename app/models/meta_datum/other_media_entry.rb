class MetaDatum::OtherMediaEntry < MetaDatum::Text
  include Concerns::MetaData::CreatedBy

  belongs_to :other_media_entry, class_name: '::MediaEntry'

  def value
    [other_media_entry_id, string].map { |i| i.presence || '' }
  end

  def value=(new_value)
    with_sanitized(new_value) do |new_value|
      self.other_media_entry_id, self.string = new_value.split(';')
    end
  end

  def set_value!(new_value, _created_by_user = nil)
    self.value = new_value[0]
    save!
  end
end
