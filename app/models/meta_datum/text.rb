class MetaDatum::Text < MetaDatum

  before_save do
    self.string =
      if self.string.blank? \
          || self.string.match(Madek::Constants::VALUE_WITH_ONLY_WHITESPACE_REGEXP)
        nil
      else
        self.string.unicode_normalize(:nfc)
      end
  end

  def value
    string
  end

  alias_method :to_s, :value
  alias_method :potential_value_for_new_record, :value

  def value=(new_value)
    with_sanitized(new_value) do |new_value|
      self.string = new_value
    end
  end

  def set_value!(new_value, _created_by_user = nil)
    self.value = new_value
    self.save!
  end

  # can't be private because it's used from elsewhere
  def with_sanitized(new_value)
    # we are using unicode [[:word]] matcher to exclude strings consisting only
    # of unicode whitespace characters (eg. \u8203). Such strings are whether
    # recognized by #blank? nor by [[:space:]] regex matcher.
    super(new_value) do |new_value|
      yield whitespace_sanitized new_value
    end
  end

  private

  def whitespace_sanitized(value)
    if value.try(:match, Madek::Constants::VALUE_WITH_ONLY_WHITESPACE_REGEXP)
      nil
    else
      value
    end
  end
end
