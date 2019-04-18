class UpgradeAppContextSettingsForV3 < ActiveRecord::Migration[4.2]
  class ::MigrationAppSetting < ActiveRecord::Base
    self.table_name = 'app_settings'
  end

  class ::MigrationContext < ActiveRecord::Base
    self.table_name = 'contexts'
  end

  class ::MigrationContextGroup < ActiveRecord::Base
    self.table_name = 'context_groups'
  end


  # NOTE: This creates/migrates the v3 Display-Metadata-in-by-Contexts settings

  def change
    change_column_default :app_settings, :id, 0

    # ADD NEW SETTINGS
    add_column :app_settings, :context_for_show_summary, :string
    %i(
      contexts_for_show_extra
      contexts_for_list_details
      contexts_for_validation
      contexts_for_dynamic_filters
    ).each do |field_name|
      add_column :app_settings, field_name, :text, array: true, default: []
    end

    app_setting = (AppSetting.first or AppSetting.create)

    # SET VALUES LIKE IN V2
    new_settings = {}

    # hardcoded setting in v2:
    new_settings[:context_for_show_summary] = 'core'

    # implicit setting in v2, by order in first ContextGroup
    new_settings[:contexts_for_show_extra] = [(
      if (magic_group = MigrationContextGroup.reorder(:position).first).present?
        MigrationContext
          .where(context_group_id: magic_group.id)
          .reorder(:position)
          .map(&:id)
      end
    )].flatten.compact

    # implicit & explicit settings in v2:
    new_settings[:contexts_for_list_details] = [
      new_settings[:context_for_show_summary],
      app_setting.second_displayed_context_id,
      app_setting.third_displayed_context_id
    ].flatten.compact

    # hardcoded setting in v2:
    new_settings[:contexts_for_validation] = ['upload']

    # implicit setting in v2, same as summary + extra:
    new_settings[:contexts_for_dynamic_filters] = [
      new_settings[:context_for_show_summary],
      new_settings[:contexts_for_show_extra]
    ].flatten.compact

    AppSetting.reset_column_information
    app_setting.update_attributes!(new_settings)

    # CLEANUP
    remove_column :app_settings, :third_displayed_context_id
    remove_column :app_settings, :second_displayed_context_id
  end
end
