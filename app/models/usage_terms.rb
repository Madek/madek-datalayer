class UsageTerms < ApplicationRecord
  validates :title, :version, :intro, :body, presence: true

  def self.most_recent
    order(created_at: :desc).first
  end
end
