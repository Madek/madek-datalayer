require 'active_support/all'

DATALAYER_PATHNAME = Pathname(File.dirname(File.absolute_path(__FILE__))).parent

require DATALAYER_PATHNAME.join('lib', 'madek', 'constants.rb')

SETTINGS_LOCATIONS = [['config', 'settings.yml'],
                      ['config', 'settings.local.yml'],
                      ['..', 'config', 'settings.yml'],
                      ['..', 'config', 'settings.local.yml'],
                      ['..', '..', 'config', 'settings.yml'],
                      ['..', '..', 'config', 'settings.local.yml']]

def ostructify(d)
  if d.is_a? Hash
    OpenStruct.new(d.map do |k, v|
      [k, ostructify(v)]
    end.to_h)
  else
    d
  end
end

def load_settings
  conf = {}.with_indifferent_access
  SETTINGS_LOCATIONS.each do |rel_location|
    if File.exists? (conf_file = DATALAYER_PATHNAME.join(*rel_location))
      conf.deep_merge! YAML.load_file conf_file
    end
  end
  ostructify(conf)
end

Settings = OpenStruct.new
Settings.send :define_singleton_method, :reload! do
  each_pair.to_h.keys do |k|
    self.delete_field k
  end
  load_settings.to_h.map do |k, v|
    self[k] = v
  end
  self
end
Settings.reload!

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
      || (DATALAYER_ROOT_DIR && DATALAYER_ROOT_DIR.join('tmp', Rails.env)) \
      || (ADMIN_ROOT_DIR && ADMIN_ROOT_DIR.join('tmp', Rails.env))

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
