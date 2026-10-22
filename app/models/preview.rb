class Preview < ApplicationRecord
  include MediaType

  attr_accessor :accessed_by_confidential_link

  belongs_to :media_file, touch: true

  before_create :set_media_type, unless: :media_type?

  def hls?
    conversion_profile == 'hls'
  end

  def hls_dir
    return unless hls?

    dir = File.dirname(file_path)
    dir if File.basename(dir) == 'hls'
  end

  def file_path
    path =
      "#{Madek::Constants::THUMBNAIL_STORAGE_DIR}/#{filename.first}/#{filename}"
    path.sub!('admin-webapp', 'webapp') if Rails.env.development?
    path
  end

  after_destroy :delete_stored_files

  def delete_stored_files
    if hls? && hls_dir
      FileUtils.rm_rf(hls_dir)
      FileUtils.rm_f(File.join(File.dirname(hls_dir), 'hls.zip'))
    else
      File.delete(file_path)
    end
  rescue => err # ignore errors on FILE deletion, but do log them:
    Rails.logger.error(err)
  end
end
