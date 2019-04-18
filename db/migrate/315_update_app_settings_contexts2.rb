class UpdateAppSettingsContexts2 < ActiveRecord::Migration[4.2]
  class ::MigrationAppSetting < ActiveRecord::Base
    self.table_name = 'app_settings'
  end

  def change
    MigrationAppSetting.reset_column_information

    reversible do |dir|
      dir.up do
        add_column :app_settings,
          :contexts_for_collection_extra, :text, array: true, default: []
      end

      dir.down do
        remove_column :app_settings, :contexts_for_collection_extra
      end
    end
  end
end
