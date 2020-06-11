class AddProvenanceNoticesToAppSettings < ActiveRecord::Migration[4.2]
  class MigrationAppSetting < ActiveRecord::Base
    self.table_name = :app_settings
  end

  def change
    add_column :app_settings, :provenance_notices, :hstore, default: {}, null: false

    reversible do |dir|
      dir.up do
        MigrationAppSetting.reset_column_information
        app_settings = MigrationAppSetting.first

        # build a usefull string for this new field by combining site_title and brand_text (per language)
        app_settings.available_locales.each do |locale|
          next unless app_settings.site_titles[locale].present?
          app_settings.provenance_notices[locale] = \
            [app_settings.brand_texts[locale],
             app_settings.site_titles[locale]]
             .join(', ')
        end
        app_settings.save!
      end
    end
  end
end
