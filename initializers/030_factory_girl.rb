if %(development test).include? Rails.env
  FactoryGirl.definition_file_paths = [
    Madek::Constants::DATALAYER_ROOT_DIR.join('spec', 'factories')
  ]
  FactoryGirl.find_definitions
end
