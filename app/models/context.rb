class Context < ActiveRecord::Base

  has_many(:context_keys,
           -> { order('context_keys.position ASC') },
           foreign_key: :context_id, dependent: :destroy)

  def to_s
    id
  end

end
