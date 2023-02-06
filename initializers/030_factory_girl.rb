require 'factory_bot'

if %(development test).include? Rails.env
  FactoryBot.definition_file_paths = [
    Madek::Constants::DATALAYER_ROOT_DIR.join('spec', 'factories')
  ]
  FactoryBot.find_definitions
end
