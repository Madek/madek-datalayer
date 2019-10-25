class MetaDatum::JSON < MetaDatum::Text

  def value
    json
  end

  def value=(new_value)
    with_sanitized(new_value) do |new_value|
      # NOTE: all updates from webapp send strings only!
      new_value = ::JSON.parse(new_value) if new_value.is_a?(String)
      self.json = new_value
    end
  end

  def set_value!(new_value, _created_by_user = nil)
    self.value = new_value
    self.save!
  end

end
