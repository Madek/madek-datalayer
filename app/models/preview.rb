# -*- encoding : utf-8 -*-
class Preview < ActiveRecord::Base
  include Concerns::MediaType

  belongs_to :media_file

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
