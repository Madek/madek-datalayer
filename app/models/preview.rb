class Preview < ApplicationRecord
  include Concerns::MediaType

  attr_accessor :accessed_by_confidential_link

  belongs_to :media_file, touch: true

  before_create :set_media_type

  def file_path
    path =
      "#{Madek::Constants::THUMBNAIL_STORAGE_DIR}/#{filename.first}/#{filename}"
    path.sub!('admin-webapp', 'webapp') if Rails.env.development?
    path
  end

  after_destroy do
    begin
      File.delete(file_path)
    rescue => err # ignore errors on FILE deletion, but do log them:
      Rails.logger.error(err)
    end
  end
end
