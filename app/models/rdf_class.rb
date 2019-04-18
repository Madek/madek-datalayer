class RdfClass < ApplicationRecord

  belongs_to :keyword # fkey not null

  def to_s
    id
  end

end
