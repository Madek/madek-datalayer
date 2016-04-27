class Keyword < ActiveRecord::Base

  include Concerns::FindResource
  include Concerns::Keywords::Filters

  belongs_to :meta_key
  belongs_to :creator, class_name: User
  has_and_belongs_to_many :meta_data, join_table: :meta_data_keywords

  def to_s
    term
  end

  def self.viewable_by_user_or_public(user = nil)
    viewable_vocabs = Vocabulary.viewable_by_user_or_public(user)
    joins(:meta_key)
      .where('meta_keys.vocabulary_id IN (?)', viewable_vocabs.map(&:id))
  end
end
