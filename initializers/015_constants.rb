require 'fileutils'

module Madek

  module Constants

    MADEK_SESSION_COOKIE_NAME = Settings.madek_session_cookie_name.presence

    def self.pathname_or_nil(path)
      if path.present?
        pathname = Pathname(path)
        FileUtils.mkpath(pathname) unless Dir.exists?(pathname)
        pathname.realpath
      end
    end

    DEFAULT_STORAGE_DIR = env_path_or_nil('MADEK_STORAGE_DIR') \
      || pathname_or_nil(Settings.default_storage_dir) \
      || (MADEK_ROOT_DIR && MADEK_ROOT_DIR.join('tmp', Rails.env)) \
      || (WEBAPP_ROOT_DIR && WEBAPP_ROOT_DIR.join('tmp', Rails.env)) \
      || (DATALAYER_ROOT_DIR && DATALAYER_ROOT_DIR.join('tmp', Rails.env))

    ZIP_STORAGE_DIR  = env_path_or_nil('MADEK_ZIP_STORAGE_DIR') \
      || pathname_or_nil(Settings.zip_storage_dir) \
      || DEFAULT_STORAGE_DIR.join('zipfiles')

    DOWNLOAD_STORAGE_DIR = env_path_or_nil('MADEK_DOWNLOAD_STORAGE_DIR') \
      || pathname_or_nil(Settings.download_storage_dir) \
      || DEFAULT_STORAGE_DIR.join('downloads')

    FILE_STORAGE_DIR = env_path_or_nil('MADEK_FILE_STORAGE_DIR') \
      || pathname_or_nil(Settings.file_storage_dir) \
      || DEFAULT_STORAGE_DIR.join('originals')

    THUMBNAIL_STORAGE_DIR = env_path_or_nil('MADEK_THUMBNAIL_STORAGE_DIR') \
      || pathname_or_nil(Settings.thumbnail_storage_dir) \
      || DEFAULT_STORAGE_DIR.join('thumbnails')

    SPECIAL_WHITESPACE_CHARS = ["\u180E",
                                "\uFEFF",
                                "\u200B",
                                "\u200C",
                                "\u200D",
                                "\u200E",
                                "\u200F"]
    WHITESPACE_REGEXP = \
      Regexp.new \
        "^([[:space:]]|#{Madek::Constants::SPECIAL_WHITESPACE_CHARS.join('|')})$"
  end
end
