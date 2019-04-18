class UpdateAppSettingsContexts < ActiveRecord::Migration[4.2]
  class ::MigrationAppSetting < ActiveRecord::Base
    self.table_name = 'app_settings'
  end

  def change
    add_column :app_settings, :contexts_for_resource_edit, :text, array: true, default: []
    add_column :app_settings, :context_for_entry_summary, :string
    add_column :app_settings, :context_for_collection_summary, :string

    rename_column :app_settings, :contexts_for_show_extra, :contexts_for_entry_extra

    MigrationAppSetting.reset_column_information

    reversible do |dir|
      app_settings = MigrationAppSetting.first
      dir.up do
        %i(
          context_for_entry_summary
          context_for_collection_summary
        ).each do |field_name|
          app_settings.update_attribute(
            field_name,
            app_settings.context_for_show_summary
          )
        end
        app_settings.update_attribute(
          :contexts_for_resource_edit,
          [
            app_settings.context_for_show_summary,
            app_settings.contexts_for_entry_extra
          ].flatten.compact
        )
      end

      dir.down do
        app_settings.update_attribute(
          :context_for_show_summary,
          app_settings.context_for_entry_summary
        )
      end
    end

    remove_column :app_settings, :context_for_show_summary, :string
  end
end
