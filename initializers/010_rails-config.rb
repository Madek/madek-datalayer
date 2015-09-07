require 'rails_config'
RailsConfig.setup do |config|
  config.const_name = 'Settings'
end

%w(settings.yml settings.local.yml).each do |settings_file_name|
  [Madek::Constants::DATALAYER_ROOT_DIR,
   Madek::Constants::WEBAPP_ROOT_DIR,
   Madek::Constants::MADEK_ROOT_DIR].each do |location|
     if location
       Settings.add_source! \
         location.join('config', settings_file_name).to_s
     end
   end
end

Settings.reload!

# Now, add some constants which can be configured and hence the Settings
# business must be configured before. Settings independent constants should go
# into lib/madek/constants.

module Madek
  module Constants

    MADEK_SESSION_COOKIE_NAME = Settings.madek_session_cookie_name.presence

    MADEK_SESSION_VALIDITY_DURATION =
      ChronicDuration.parse(Settings.madek_session_validity_duration).seconds

    def self.env_path_or_nil(env_var)
      ENV[env_var].present? && Pathname(ENV[env_var]).realpath
    end

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

  end
end
