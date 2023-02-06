require 'active_support/all'
require_relative './pojo'

module SettingsHelper
  class << self

    DATALAYER_PATHNAME = \
      Pathname(File.dirname(File.absolute_path(__FILE__))).parent

    SETTINGS_LOCATIONS = [['config', 'settings.yml'],
                          ['config', 'settings.local.yml'],
                          ['..', 'config', 'settings.yml'],
                          ['..', 'config', 'settings.local.yml'],
                          ['..', '..', 'config', 'settings.yml'],
                          ['..', '..', 'config', 'settings.local.yml']]

    DEV_SETTINGS = ['..', 'config', 'settings.dev.yml']

    def ostructify(d)
      if d.is_a? Hash
        Pojo.new(d.map do |k, v|
          [k, ostructify(v)]
        end.to_h)
      else
        d
      end
    end

    def load_settings
      settings_locations = SETTINGS_LOCATIONS
      settings_locations.push(DEV_SETTINGS) if Rails.env.development?
      conf = {}.with_indifferent_access
      settings_locations.each do |rel_location|
        if File.exist? (conf_file = DATALAYER_PATHNAME.join(*rel_location))
          conf.deep_merge! YAML.load_file conf_file
        end
      end
      ostructify(conf)
    end

  end
end

::Settings = OpenStruct.new
::Settings.send :define_singleton_method, :reload! do
  each_pair.to_h.keys do |k|
    self.delete_field k
  end
  SettingsHelper.load_settings.to_h.map do |k, v|
    self[k] = v
  end
  self
end
::Settings.reload!
