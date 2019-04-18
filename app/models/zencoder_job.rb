class ZencoderJob < ApplicationRecord
  belongs_to :media_file

  def self.config
    config_path = Madek::Constants::WEBAPP_ROOT_DIR +
      (ENV['ZENCODER_CONFIG_FILE'] || Rails.root.join('config', 'zencoder.yml'))
    @config ||= YAML.load_file(config_path)['zencoder']
  end

  def submitted?
    state == 'submitted'
  end

  def fetch_progress
    data = Zencoder::Job.progress(zencoder_id).body
    if data['state'] == 'processing'
      update_attribute(:progress, data['progress'])
    end
    progress
  end
end
