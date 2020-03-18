class MigrateDefaultLicenseHackToAppSettings < ActiveRecord::Migration[4.2]

  # add an app setting to hold the default license,
  # then apply the logic from the current upload controller to find one and set it

  class ::MigrationAppSetting < ActiveRecord::Base
    self.table_name = :app_settings
  end
  class ::MigrationLicense < ActiveRecord::Base
    self.table_name = :licenses
  end
  class ::MigrationMetaKey < ActiveRecord::Base
    self.table_name = :meta_keys
  end

  def up
    add_column :app_settings, :media_entry_default_license_id, :uuid, null: true, default: nil
    add_column :app_settings, :media_entry_default_license_meta_key, :text, null: true, default: nil
    add_column :app_settings, :media_entry_default_license_usage_text, :text, null: true, default: nil
    add_column :app_settings, :media_entry_default_license_usage_meta_key, :text, null: true, default: nil
    MigrationAppSetting.reset_column_information

    # NOTE: prefers the ZHdK config, but works for any instance
    meta_key_usage = MetaKey.find_by(id: 'copyright:copyright_usage') ||
      MetaKey.find_by(id: 'madek_core:copyright_notice')

    meta_key_license = MigrationMetaKey.find_by(id: 'copyright:license') \
      || MigrationMetaKey.where(meta_datum_object_type: 'MetaDatum::Licenses').first

    license = MigrationLicense.where(is_default: true).first

    MigrationAppSetting.first.update_attributes!({
      media_entry_default_license_id: license.try(:id),
      media_entry_default_license_meta_key: meta_key_license.try(:id),
      media_entry_default_license_usage_text: license.try(:usage),
      media_entry_default_license_usage_meta_key: meta_key_usage.try(:id)
    })

  end
end
