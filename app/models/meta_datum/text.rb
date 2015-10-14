# -*- encoding : utf-8 -*-

class MetaDatum::Text < MetaDatum

  def value
    string
  end

  alias_method :to_s, :value

  def value=(new_value)
    with_sanitized(new_value) do |new_value|
      self.string = new_value
    end
  end

  def set_value!(new_value, _created_by_user = nil)
    self.value = new_value
    self.save!
  end

  private

  def with_sanitized(new_value)
    # we are using unicode [[:word]] matcher to exclude strings consisting only
    # of unicode whitespace characters (eg. \u8203). Such strings are whether
    # recognized by #blank? nor by [[:space:]] regex matcher.
    super(new_value) do |new_value|
      yield whitespace_sanitized new_value if new_value
    end
  end

  def whitespace_sanitized(value)
    value.match(Madek::Constants::WHITESPACE_REGEXP) ? nil : value
  end
end
