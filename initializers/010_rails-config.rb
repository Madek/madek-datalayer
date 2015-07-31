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
