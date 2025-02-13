class Keyword < ApplicationRecord

  include FindResource
  include Keywords::Filters
  include Orderable
  include PreviousId

  enable_ordering skip_default_scope: true,
                  parent_scope: :meta_key

  belongs_to :meta_key
  belongs_to :creator, class_name: 'User'
  has_and_belongs_to_many :meta_data, join_table: :meta_data_keywords
  has_many :meta_data_keywords, class_name: '::MetaDatum::Keyword'
  has_one :section

  validate do
    if self.term.blank? or
        self.term.match(Madek::Constants::VALUE_WITH_ONLY_WHITESPACE_REGEXP)
      errors.add(:base, "Term can't be blank")
    end
  end

  def to_s
    term
  end

  before_save do
    self.term = self.term.gsub(Madek::Constants::TRIM_WHITESPACE_REGEXP, '')
    self.term = if self.term.present?
                  self.term.unicode_normalize(:nfc)
                end
  end

  def not_used?
    self.class.usage_count_for(self).empty?
  end

  def usage_count
    self[:usage_count].presence || 
      ( entries_usage_count + collections_usage_count )
  end

  def entries_usage_count
    self[:entries_usage_count].presence ||
      meta_data_keywords
      .joins(:meta_datum)
      .where('meta_data.media_entry_id IS NOT NULL')
      .count
  end

  def collections_usage_count
    self[:collections_usage_count].presence ||
      meta_data_keywords
      .joins(:meta_datum)
      .where('meta_data.collection_id IS NOT NULL')
      .count
  end

  def merge_to(receiver)
    ActiveRecord::Base.transaction do
      meta_data.each do |md|
        old_mdk = md.meta_data_keywords.find_by(keyword_id: self.id)
        if md.meta_data_keywords.find_by(keyword_id: receiver.id)
          old_mdk.destroy!
        else 
          old_mdk.update_columns(
            keyword_id: receiver.id,
            created_by_id: receiver.creator_id
          )
        end
      end
      remember_previous_ids!(receiver)
      destroy!
    end
  end

  def self.viewable_by_user_or_public(user = nil)
    viewable_vocabs = Vocabulary.viewable_by_user_or_public(user.try(:id))
    joins(:meta_key)
      .where('meta_keys.vocabulary_id IN (?)', viewable_vocabs.map(&:id))
  end

  def self.with_usage_count
    select('keywords.*, count(meta_data_keywords.id) AS usage_count')
      .joins('INNER JOIN meta_data_keywords ' \
             'ON meta_data_keywords.keyword_id = keywords.id')
      .group('keywords.id')
      .reorder('usage_count DESC')
  end

  def self.all_with_usage_count
    select('keywords.*, count(meta_data_keywords.id) AS usage_count')
      .joins('LEFT OUTER JOIN meta_data_keywords AS meta_data_keywords ' \
             'ON meta_data_keywords.keyword_id = keywords.id')
      .group('keywords.id')
  end

  def self.usage_count_for(record_or_relation, mr_type: nil)
    ids = if record_or_relation.is_a?(ActiveRecord::Relation)
            record_or_relation.pluck(:id)
          else
            record_or_relation.try!(:id)
          end

    scope =
      select('keywords.*, count(keywords.id) AS usage_count')
      .joins('INNER JOIN meta_data_keywords ' \
             'ON meta_data_keywords.keyword_id = keywords.id')
      .joins('INNER JOIN meta_data '\
             'ON meta_data.id = meta_data_keywords.meta_datum_id')
      .group('keywords.id')
      .where(keywords: { id: ids })

    if mr_type == :entries
      scope = scope
        .joins('INNER JOIN media_entries ' \
               'ON media_entries.id = meta_data.media_entry_id')
    elsif mr_type == :collections
      scope = scope
        .joins('INNER JOIN collections ' \
               'ON collections.id = meta_data.collection_id')
    end

    {}.tap do |hash|
      scope.each do |keyword|
        hash[keyword.id] = keyword[:usage_count]
      end
    end
  end

  def self.entries_usage_count_for(record_or_relation)
    usage_count_for(record_or_relation, mr_type: :entries)
  end

  def self.collections_usage_count_for(record_or_relation)
    usage_count_for(record_or_relation, mr_type: :collections)
  end
end
