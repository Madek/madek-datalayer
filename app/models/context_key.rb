class ContextKey < ActiveRecord::Base
  include Concerns::Orderable

  belongs_to :context, foreign_key: :context_id
  belongs_to :meta_key

  enum text_element: {
    input: 'input',
    textarea: 'textarea'
  }

  def multiline?
    return nil unless self.meta_key_string?
    definition = self
    case
    # explicit config:
    when !definition.text_element.nil?
      definition.text_element != 'text_area' ? false : true
    # otherwise implicit config:
    when !definition.length_max.nil?
      definition.length_max >= 255 ? true : false
    # default
    else
      true
    end
  end

  def move_up
    move :up, context_id: context.id
  end

  def move_down
    move :down, context_id: context.id
  end

end
