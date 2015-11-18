class ZencoderJob < ActiveRecord::Base
  belongs_to :media_file

  def self.config
    config_path = Madek::Constants::WEBAPP_ROOT_DIR +
      (ENV['ZENCODER_CONFIG_FILE'] || Rails.root.join('config', 'zencoder.yml'))
    @config ||= YAML.load_file(config_path)['zencoder']
  end
end
