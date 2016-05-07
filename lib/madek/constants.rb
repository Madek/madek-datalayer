require 'settings'
require 'chronic_duration'
ChronicDuration.raise_exceptions = true

module Madek
  module Constants

    DATALAYER_ROOT_DIR = \
      Pathname(File.dirname(File.absolute_path(__FILE__))).parent.parent

    MADEK_ROOT_DIR = DATALAYER_ROOT_DIR.join('..', '..')

    WEBAPP_ROOT_DIR = MADEK_ROOT_DIR.join('webapp')

    ADMIN_ROOT_DIR = MADEK_ROOT_DIR.join('admin-webapp')

    def self.env_path_or_nil(env_var)
      ENV[env_var].present? && Pathname(ENV[env_var]).realpath
    end

    def self.pathname_or_nil(path)
      if path.present?
        pathname = Pathname(path)
        FileUtils.mkpath(pathname) unless Dir.exist?(pathname)
        pathname.realpath
      end
    end

    DEFAULT_STORAGE_DIR = env_path_or_nil('MADEK_STORAGE_DIR') \
      || pathname_or_nil(Settings.default_storage_dir) \
      || (MADEK_ROOT_DIR && MADEK_ROOT_DIR.join('tmp', Rails.env)) \
      || (WEBAPP_ROOT_DIR && WEBAPP_ROOT_DIR.join('tmp', Rails.env)) \
      || (DATALAYER_ROOT_DIR && DATALAYER_ROOT_DIR.join('tmp', Rails.env)) \
      || (ADMIN_ROOT_DIR && ADMIN_ROOT_DIR.join('tmp', Rails.env))

    ZIP_STORAGE_DIR = env_path_or_nil('MADEK_ZIP_STORAGE_DIR') \
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

    THUMBNAILS = { maximum: nil,
                   x_large: { width: 1024, height: 768 },
                   large: { width: 620, height: 500 },
                   medium: { width: 300, height: 300 },
                   small_125: { width: 125, height: 125 },
                   small: { width: 100, height: 100 } }

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

    MADEK_V2_PERMISSION_ACTIONS = [:download, :edit, :manage, :view]

    MADEK_SESSION_COOKIE_NAME = Settings.madek_session_cookie_name.presence

    MADEK_SESSION_VALIDITY_DURATION =
      ChronicDuration.parse(Settings.madek_session_validity_duration).seconds

  end
end
