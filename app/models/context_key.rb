class ContextKey < ActiveRecord::Base
  include Concerns::Orderable
  include Concerns::NullifyEmptyStrings

  belongs_to :context, foreign_key: :context_id
  belongs_to :meta_key

  enable_ordering skip_default_scope: true, parent_scope: :context
  nullify_empty :label, :description, :hint

  def move_up
    move :up, context_id: context.id
  end

  def move_down
    move :down, context_id: context.id
  end

end
