class MetaKey < ActiveRecord::Base

  include Concerns::MetaKeys::Filters
  include Concerns::Orderable
  include Concerns::NullifyEmptyStrings

  has_many :meta_data, dependent: :destroy
  belongs_to :vocabulary
  has_many :context_keys

  #################################################################################
  # NOTE: order of statements is important here! ##################################
  #################################################################################
  # (1.)
  has_many :keywords

  # (2.) override one of the methods provided by (1.)
  def keywords
    ks = Keyword.where(meta_key_id: id)
    keywords_alphabetical_order ? ks.order('keywords.term ASC') : ks
  end
  #################################################################################

  scope :order_by_name_part, lambda {
    reorder("substring(meta_keys.id FROM ':(.*)$') ASC, meta_keys.id")
  }
  scope :with_keywords_count, lambda {
    joins(
      'LEFT OUTER JOIN keywords ON
       keywords.meta_key_id = meta_keys.id'
    )
      .select('meta_keys.*, count(keywords.id) as keywords_count')
      .group('meta_keys.id')
  }

  nullify_empty :label, :description, :hint
  before_validation :sanitize_allowed_people_subtypes

  def self.object_types
    unscoped \
      .select(:meta_datum_object_type)
      .distinct
      .order(:meta_datum_object_type)
      .map(&:meta_datum_object_type)
  end

  def can_have_keywords?
    meta_datum_object_type == 'MetaDatum::Keywords'
  end

  def can_have_people_subtypes?
    meta_datum_object_type == 'MetaDatum::People'
  end

  def self.viewable_by_user_or_public(user = nil)
    viewable_vocabs = Vocabulary.viewable_by_user_or_public(user)
    where(vocabulary_id: viewable_vocabs)
  end

  def viewable_by_user_or_public?(user = nil)
    viewable_meta_keys = self.class.viewable_by_user_or_public(user)
    viewable_meta_keys.include? self
  end

  def move_up
    move :up, vocabulary_id: vocabulary.id
  end

  def move_down
    move :down, vocabulary_id: vocabulary.id
  end

  private

  def sanitize_allowed_people_subtypes
    # do not run for previous migrations
    return unless respond_to?(:allowed_people_subtypes)
    return unless allowed_people_subtypes.is_a?(Array)
    self.allowed_people_subtypes = allowed_people_subtypes.reject(&:blank?)
  end
end
