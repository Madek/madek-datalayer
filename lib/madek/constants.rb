require 'yaml'

module Madek

  module Constants

    # set also initializers/015_constants.rb for more constants definitions
    # like DEFAULT_STORAGE_DIR, FILE_STORAGE_DIR, etc

    def self.env_path_or_nil(env_var)
      ENV[env_var].present? && Pathname(ENV[env_var]).realpath
    end

    case
    when File.exists?('.madek-datalayer')
      DATALAYER_ROOT_DIR = Pathname('.').realpath

      MADEK_ROOT_DIR =
        if File.exists?(DATALAYER_ROOT_DIR.join('..', '..', '..', '.madek'))
          DATALAYER_ROOT_DIR.join('..', '..', '..').realpath
        end

      WEBAPP_ROOT_DIR =
        if File.exists?(DATALAYER_ROOT_DIR.join('..', '..', '.madek-webapp'))
          DATALAYER_ROOT_DIR.join('..', '..').realpath
        end

    when File.exists?('.madek-webapp')
      WEBAPP_ROOT_DIR = Pathname('.').realpath

      DATALAYER_ROOT_DIR =
        if File.exists?(WEBAPP_ROOT_DIR.join('engines', 'datalayer',
                                             '.madek-datalayer'))
          WEBAPP_ROOT_DIR.join('engines', 'datalayer').realpath
        end

      MADEK_ROOT_DIR =
        if File.exists?(WEBAPP_ROOT_DIR.join('..', '.madek'))
          WEBAPP_ROOT_DIR.join('..').realpath
        end

    else
      raise 'unknown starting location'
    end

    MADEK_V2_PERMISSION_ACTIONS = [:download, :edit, :manage, :view]

  end
end
