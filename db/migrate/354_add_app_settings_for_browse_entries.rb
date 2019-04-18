class AddAppSettingsForBrowseEntries < ActiveRecord::Migration[4.2]

  KEY = :ignored_keyword_keys_for_browsing

  class ::MigrationAppSetting < ActiveRecord::Base
    self.table_name = :app_settings
  end
  class ::MigrationMetaKey < ActiveRecord::Base
    self.table_name = :meta_keys
  end

  def up
    add_column :app_settings, KEY, :text, null: true, default: nil
    MigrationAppSetting.reset_column_information

    # NOTE: set a useful default, ignore the key used for licenses
    meta_key_license = MigrationMetaKey
      .find_by(id: MigrationAppSetting.first.media_entry_default_license_meta_key)

    if meta_key_license
      MigrationAppSetting.first.update_attributes!(KEY => meta_key_license.id)
    end

  end
end
