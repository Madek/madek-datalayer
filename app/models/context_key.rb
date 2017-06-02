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

  def move_to_top
    ActiveRecord::Base.transaction do
      regenerate_positions(scope: { context_id: context.id })
      new_position = 0
      context.context_keys.where('position < ?', position).each do |sibling|
        sibling.increment(:position)
        sibling.save!
      end
      update_attribute(:position, new_position)
    end
  end

  def move_to_bottom
    ActiveRecord::Base.transaction do
      regenerate_positions(scope: { context_id: context.id })
      new_position = context.context_keys.maximum(:position)
      context.context_keys.where('position > ?', position).each do |sibling|
        sibling.decrement(:position)
        sibling.save!
      end
      update_attribute(:position, new_position)
    end
  end

end
