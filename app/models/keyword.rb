class Keyword < ApplicationRecord

  include Concerns::FindResource
  include Concerns::Keywords::Filters
  include Concerns::Orderable

  enable_ordering skip_default_scope: true,
                  parent_scope: :meta_key

  belongs_to :meta_key
  belongs_to :creator, class_name: 'User'
  has_and_belongs_to_many :meta_data, join_table: :meta_data_keywords
  has_many :meta_data_keywords, class_name: '::MetaDatum::Keyword'

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
    self[:usage_count].presence || meta_data_keywords.count
  end

  def merge_to(receiver)
    ActiveRecord::Base.transaction do
      meta_data_keywords.each do |mdk|
        mdk.update_columns(
          keyword_id: receiver.id,
          created_by_id: receiver.creator_id
        )
      end
      destroy!
    end
  end

  def self.viewable_by_user_or_public(user = nil)
    viewable_vocabs = Vocabulary.viewable_by_user_or_public(user)
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

  def self.usage_count_for(record_or_relation)
    ids = if record_or_relation.is_a?(ActiveRecord::Relation)
            record_or_relation.pluck(:id)
          else
            record_or_relation.try!(:id)
          end

    scope = select('keywords.*, count(keywords.id) AS usage_count')
              .joins('INNER JOIN meta_data_keywords ' \
                     'ON meta_data_keywords.keyword_id = keywords.id')
              .joins('INNER JOIN meta_data '\
                     'ON meta_data.id = meta_data_keywords.meta_datum_id')
              .joins('INNER JOIN media_entries ' \
                     'ON media_entries.id = meta_data.media_entry_id')
              .group('keywords.id')
              .where(keywords: { id: ids })

    {}.tap do |hash|
      scope.each do |keyword|
        hash[keyword.id] = keyword[:usage_count]
      end
    end
  end

  # used in explore catalog
  def self.for_meta_key_and_used_in_visible_entries_with_previews(meta_key,
                                                                  user,
                                                                  limit)
    with_usage_count
      .where(meta_key: meta_key)
      .joins('INNER JOIN meta_data ' \
             'ON meta_data.id = meta_data_keywords.meta_datum_id')
      .where(
        meta_data: {
          media_entry_id: MediaEntry
                          .viewable_by_user_or_public(user)
                          .joins(:media_file)
                          .joins('INNER JOIN previews ' \
                                 'ON previews.media_file_id = media_files.id')
                          .where(previews: { media_type: 'image' })
        }
      )
      .limit(limit)
  end
end
