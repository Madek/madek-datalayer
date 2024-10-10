class MetaKey < ApplicationRecord

  include MetaKeys::Filters
  include MetaKeys::MetaDatumObjectType::Keywords
  include MetaKeys::MetaDatumObjectType::PeopleRoles
  include MetaKeys::MetaDatumObjectType::Text
  include Orderable
  include LocalizedFields
  include HasDocumentationUrl

  has_many :meta_data
  belongs_to :vocabulary
  has_many :context_keys

  enum :text_type, { line: 'line', block: 'block' }

  scope :order_by_name_part, lambda {
    reorder(Arel.sql "substring(meta_keys.id FROM ':(.*)$') ASC, meta_keys.id")
  }

  enable_ordering parent_scope: :vocabulary
  localize_fields :labels, :descriptions, :hints, :documentation_urls

  def core?
    vocabulary_id == 'madek_core'
  end

  def self.object_types
    [MetaDatum::JSON, MetaDatum::Keywords, MetaDatum::MediaEntry,
      MetaDatum::People, MetaDatum::Roles, MetaDatum::Text, MetaDatum::TextDate]
      .map(&:name)
      .sort
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
end
