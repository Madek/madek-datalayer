require 'yaml'
require 'pathname'

DATALAYER_DIR = Pathname.new(File.dirname(__FILE__)).join("../..").expand_path
DATABASE_YML_PATH = DATALAYER_DIR.join("config", "database.yml")

db_config = {
  'adapter' => 'postgresql',
  'encoding' => 'unicode',
  'host' => 'localhost',
  'pool' => 3,
  'port' => ENV['PG15PORT'],
  'username' => ENV['PG15USER'],
  'password' =>  ENV['PGPASSWORD'],
  'database' => ENV['DATABASE']}

config = { 'test' => db_config, 'production' => db_config }
File.open(DATABASE_YML_PATH, 'w') { |file| 
  file.write config.to_yaml }
