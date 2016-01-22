require 'fileutils'
require 'yaml'

require 'chronic_duration'
ChronicDuration.raise_exceptions = true

module Madek

  module Constants

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

      ADMIN_ROOT_DIR =
        if File.exists?(DATALAYER_ROOT_DIR.join('..', '..', '.madek-admin'))
          DATALAYER_ROOT_DIR.join('..', '..').realpath
        end

    when File.exists?('.madek-webapp')
      WEBAPP_ROOT_DIR = Pathname('.').realpath

      ADMIN_ROOT_DIR =
        if File.exists?(WEBAPP_ROOT_DIR.join('..', 'admin-webapp', '.madek-admin'))
          WEBAPP_ROOT_DIR.join('..', 'admin-webapp').realpath
        end

      DATALAYER_ROOT_DIR =
        if File.exists?(WEBAPP_ROOT_DIR.join('engines', 'datalayer',
                                             '.madek-datalayer'))
          WEBAPP_ROOT_DIR.join('engines', 'datalayer').realpath
        end

      MADEK_ROOT_DIR =
        if File.exists?(WEBAPP_ROOT_DIR.join('..', '.madek'))
          WEBAPP_ROOT_DIR.join('..').realpath
        end

    when File.exists?('.madek-api')
      API_ROOT_DIR = Pathname('.').realpath

      WEBAPP_ROOT_DIR =
        if File.exists?(API_ROOT_DIR.join('..', 'webapp', '.madek-webapp'))
          API_ROOT_DIR.join('..', 'webapp').realpath
        end

      ADMIN_ROOT_DIR =
        if File.exists?(API_ROOT_DIR.join('..', 'admin-webapp', '.madek-admin'))
          API_ROOT_DIR.join('..', 'admin-webapp').realpath
        end

      DATALAYER_ROOT_DIR =
        if File.exists?(API_ROOT_DIR.join('datalayer', '.madek-datalayer'))
          API_ROOT_DIR.join('datalayer').realpath
        end

      MADEK_ROOT_DIR =
        if File.exists?(API_ROOT_DIR.join('..', '.madek'))
          API_ROOT_DIR.join('..').realpath
        end

    when File.exists?('.madek-admin')
      ADMIN_ROOT_DIR = Pathname('.').realpath

      WEBAPP_ROOT_DIR =
        if File.exists?(ADMIN_ROOT_DIR.join('..', 'webapp', '.madek-webapp'))
          ADMIN_ROOT_DIR.join('..', 'webapp').realpath
        end

      DATALAYER_ROOT_DIR =
        if File.exists?(ADMIN_ROOT_DIR.join('engines', 'datalayer',
                                            '.madek-datalayer'))
          ADMIN_ROOT_DIR.join('engines', 'datalayer').realpath
        end

      MADEK_ROOT_DIR =
        if File.exists?(ADMIN_ROOT_DIR.join('..', '.madek'))
          ADMIN_ROOT_DIR.join('..').realpath
        end

    else
      raise 'unknown starting location'
    end

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

  end
end
