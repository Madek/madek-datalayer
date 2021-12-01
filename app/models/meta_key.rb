class MetaKey < ApplicationRecord

  include Concerns::MetaKeys::Filters
  include Concerns::Orderable
  include Concerns::LocalizedFields
  include Concerns::HasDocumentationUrl

  has_many :meta_data
  belongs_to :vocabulary
  has_many :context_keys
  has_many :roles

  enum text_type: { line: 'line', block: 'block' }

  #################################################################################
  # NOTE: order of statements is important here! ##################################
  #################################################################################
  # (1.)
  has_many :keywords

  # (2.) override one of the methods provided by (1.)
  def keywords
    ks = Keyword.where(meta_key_id: id)
    if keywords_alphabetical_order
      ks.order('keywords.term ASC')
    else
      ks.order('keywords.position ASC')
    end
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

  enable_ordering parent_scope: :vocabulary
  localize_fields :labels, :descriptions, :hints, :documentation_urls
  before_validation :sanitize_allowed_people_subtypes
  before_save :keep_keywords_order_if_needed

  def self.object_types
    MetaDatum
      .descendants
      .map(&:name)
      .sort
  end

  def can_have_keywords?
    meta_datum_object_type == 'MetaDatum::Keywords'
  end

  def can_have_people_subtypes?
    meta_datum_object_type == 'MetaDatum::People'
  end

  def can_have_roles?
    meta_datum_object_type == 'MetaDatum::Roles'
  end

  def can_have_allowed_rdf_class?
    meta_datum_object_type == 'MetaDatum::Keywords'
  end

  def can_have_text_type?
    meta_datum_object_type == 'MetaDatum::Text'
  end

  def allowed_people_subtypes
    if can_have_roles?
      %w(Person PeopleGroup)
    else
      self[:allowed_people_subtypes]
    end
  end

  def self.viewable_by_user_or_public(user = nil)
    viewable_vocabs = Vocabulary.viewable_by_user_or_public(user)
    where(vocabulary_id: viewable_vocabs)
  end

  def viewable_by_user_or_public?(user = nil)
    viewable_meta_keys = self.class.viewable_by_user_or_public(user)
    viewable_meta_keys.include? self
  end

  def enabled_for
    [
      [:media_entries, 'Entries'], # [[class, name]]
      [:collections, 'Sets']
    ].select { |type| send("is_enabled_for_#{type[0]}") }
    .map(&:second)
  end

  private

  def keep_keywords_order_if_needed
    if keywords_alphabetical_order_changed? && !keywords_alphabetical_order
      unless keywords.empty?
        Keyword.transaction do
          keywords.reorder('term ASC').each_with_index do |keyword, index|
            keyword.update_column :position, index
          end
        end
      end
    end
  end

  def sanitize_allowed_people_subtypes
    # do not run for previous migrations
    return unless respond_to?(:allowed_people_subtypes)
    return unless allowed_people_subtypes.is_a?(Array)
    self.allowed_people_subtypes = allowed_people_subtypes.reject(&:blank?)
  end
end
