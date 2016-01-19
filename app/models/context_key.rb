class ContextKey < ActiveRecord::Base

  belongs_to :context, foreign_key: :context_id
  belongs_to :meta_key

  default_scope { order('position ASC') }

  # TODO: migrate this to bool, db default instead of method:
  enum input_type: [:text_field, :text_area]
  def multiline?
    return nil unless self.meta_key_string?
    definition = self
    case
    # explicit config:
    when !definition.input_type.nil?
      definition.input_type != 'text_area' ? false : true
    # otherwise implicit config:
    when !definition.length_max.nil?
      definition.length_max >= 255 ? true : false
    # default
    else
      true
    end
  end

end
