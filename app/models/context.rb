class Context < ApplicationRecord
  include Concerns::LocalizedFields

  has_many(:context_keys,
           -> { order('context_keys.position ASC') },
           foreign_key: :context_id, dependent: :destroy)

  localize_fields :labels, :descriptions

  def to_s
    id
  end

end
