module CacheHelper
  def self.catalog_cache_duration
    ActiveSupport::Duration.parse(Settings.catalog_cache_duration)
  end
end
