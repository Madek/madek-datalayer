class AddLocalizedFieldsToAppSettings < ActiveRecord::Migration[4.2]
  class MigrationAppSetting < ActiveRecord::Base
    self.table_name = :app_settings
  end

  FIELDS = %w(site_title brand_text welcome_title welcome_text featured_set_title
              featured_set_subtitle catalog_title catalog_subtitle
              about_page support_url).freeze

  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')

    FIELDS.each do |field|
      add_column :app_settings, field.pluralize, :hstore, default: {}, null: false
    end

    MigrationAppSetting.reset_column_information

    execute 'SET session_replication_role = replica;'
    FIELDS.each do |field|
      app_settings[field.pluralize] = { default_locale => app_settings[field] }
    end
    app_settings.save!

    FIELDS.each do |field|
      remove_column :app_settings, field
    end
    execute 'SET session_replication_role = DEFAULT;'
  end

  private

  def app_settings
    @_app_settings ||= MigrationAppSetting.first
  end

  def default_locale
    Settings.madek_default_locale
  end
end
