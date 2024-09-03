require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MadekDatalayer
  class Application < Rails::Application
    config.active_record.schema_format = :sql
    config.active_record.timestamped_migrations = false

    config.paths['config/initializers'] \
      << Rails.root.join('initializers')

    config.autoload_paths << Rails.root.join('lib')

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    config.active_record.belongs_to_required_by_default = false

    if ENV['RAILS_LOG_LEVEL'].present?
      config.log_level = ENV['RAILS_LOG_LEVEL']
    else
      config.log_level = :info
    end

    config.active_record.legacy_connection_handling = false

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
