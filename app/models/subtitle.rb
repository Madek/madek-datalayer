class Subtitle < ApplicationRecord
  KINDS = %w(subtitles chapters).freeze
  MAX_BYTES = 1.megabyte

  belongs_to :media_file

  validates :language, presence: true, format: { with: /\A[a-z]{2,3}(-[a-z0-9]{2,8})?\z/ }
  validates :kind, inclusion: { in: KINDS }
  validates :filename, presence: true
  validates :content, presence: true
  validate :webvtt_content
  validate :content_size

  def self.store!(media_file:, language:, kind:, label:, filename:, content:, is_default:)
    language = language.to_s.strip.downcase
    kind = kind.presence || 'subtitles'
    label = label.to_s.strip.presence || language

    transaction do
      subtitle = media_file.subtitles.find_or_initialize_by(language: language, kind: kind)
      if is_default
        scope = media_file.subtitles.where(kind: kind, is_default: true)
        scope = scope.where.not(id: subtitle.id) if subtitle.persisted?
        scope.update_all(is_default: false)
      end
      subtitle.label = label
      subtitle.filename = filename
      subtitle.content = content.to_s.sub(/\A\uFEFF/, '')
      subtitle.is_default = is_default
      subtitle.save!
      subtitle
    end
  end

  private

  def webvtt_content
    return if content.blank?
    return if content.lstrip.start_with?('WEBVTT')

    errors.add(:content, :invalid)
  end

  def content_size
    return if content.blank?
    return if content.bytesize <= MAX_BYTES

    errors.add(:content, :too_long, count: MAX_BYTES)
  end
end
