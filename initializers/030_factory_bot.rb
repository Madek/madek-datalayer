require 'factory_bot'

Rails.application.reloader.to_prepare do
  if Rails.env.test?
    FactoryBot.definition_file_paths.prepend Madek::Constants::DATALAYER_ROOT_DIR.join('spec', 'factories')
    FactoryBot.find_definitions
  end
end
