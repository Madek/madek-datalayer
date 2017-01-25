class Keyword < ActiveRecord::Base

  include Concerns::FindResource
  include Concerns::Keywords::Filters
  include Concerns::Orderable

  enable_ordering(skip_default_scope: true)

  belongs_to :meta_key
  belongs_to :creator, class_name: User
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

  before_create do
    begin
      self.position = meta_key.keywords.maximum(:position) + 1
    rescue
      self.position = 0
    end
  end

  def move_up
    move :up, meta_key_id: meta_key.id
  end

  def move_down
    move :down, meta_key_id: meta_key.id
  end

  def not_used?
    meta_data.pluck(:media_entry_id).empty?
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
    select('keywords.*, count(keywords.id) AS usage_count')
      .joins('INNER JOIN meta_data_keywords ' \
             'ON meta_data_keywords.keyword_id = keywords.id')
      .group('keywords.id')
      .reorder('usage_count DESC')
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
