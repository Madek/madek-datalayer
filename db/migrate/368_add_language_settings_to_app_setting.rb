class AddLanguageSettingsToAppSetting < ActiveRecord::Migration
  class MigrationAppSetting < ActiveRecord::Base
    self.table_name = :app_settings
  end

  def change
    add_column :app_settings, :default_locale, :string, default: :de
    add_column :app_settings, :available_locales, :string, array: true, default: []

    reversible do |dir|
      dir.up do
        MigrationAppSetting.reset_column_information
        app_setting = MigrationAppSetting.first
        app_setting.default_locale = Settings.madek_default_locale
        app_setting.available_locales = Settings.madek_available_locales
        app_setting.save!
      end
    end
  end
end
