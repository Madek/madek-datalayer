class SplitContextsForResourceEditFromAppSettings < ActiveRecord::Migration[4.2]
  class ::MigrationAppSetting < ActiveRecord::Base
    self.table_name = 'app_settings'
  end

  def change
    add_column :app_settings, :contexts_for_entry_edit, :text, array: true, default: []
    add_column :app_settings, :contexts_for_collection_edit, :text, array: true, default: []

    MigrationAppSetting.reset_column_information

    reversible do |dir|
      app_settings = MigrationAppSetting.first

      dir.up do
        app_settings.update_attributes(
          contexts_for_entry_edit: app_settings.contexts_for_resource_edit,
          contexts_for_collection_edit: app_settings.contexts_for_resource_edit
        )
      end

      dir.down do
        app_settings.update_attributes(
          contexts_for_resource_edit: app_settings.contexts_for_entry_edit
        )
      end
    end

    remove_column :app_settings, :contexts_for_resource_edit, :text, array: true, default: []
  end
end
