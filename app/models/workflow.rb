class Workflow < ApplicationRecord
  belongs_to :user
  has_many :collections

  def master_collection
    collections.find_by(is_master: true)
  end
end
