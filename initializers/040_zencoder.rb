Rails.application.config.to_prepare do
  Zencoder.api_key = Settings.zencoder_api_key if defined?(Zencoder)
end
