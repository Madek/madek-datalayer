require 'yaml'

module Madek

  module Constants

    def self.env_path_or_nil(env_var)
      ENV[env_var].present? && Pathname(ENV[env_var]).realpath
    end

    def self.guess_datalayer_root_dir
      project = YAML.load_file 'project.yml'
      case project['name']
      when 'madek-datalayer'
        Pathname('.').realpath
      when 'madek-webapp'
        Pathname('.').join('engines', 'datalayer').realpath
      else
        raise 'unknown location'
      end
    end

    DATALAYER_ROOT_DIR = guess_datalayer_root_dir

    MADEK_ROOT_DIR = env_path_or_nil('MADEK_ROOT_DIR') \
      || Rails.root

    STORAGE_DIR = env_path_or_nil('MADEK_STORAGE_DIR') \
      || MADEK_ROOT_DIR.join('tmp', Rails.env)

    ZIP_STORAGE_DIR  = env_path_or_nil('MADEK_ZIP_STORAGE_DIR') \
      || STORAGE_DIR.join('zipfiles')

    DOWNLOAD_STORAGE_DIR = env_path_or_nil('MADEK_DOWNLOAD_STORAGE_DIR') \
      || STORAGE_DIR.join('downloads')

    FILE_STORAGE_DIR = env_path_or_nil('MADEK_FILE_STORAGE_DIR') \
      || STORAGE_DIR.join('originals')

    THUMBNAIL_STORAGE_DIR = env_path_or_nil('MADEK_THUMBNAIL_STORAGE_DIR') \
      || STORAGE_DIR.join('thumbnails')

    MADEK_V2_PERMISSION_ACTIONS = [:download, :edit, :manage, :view]

  end
end
