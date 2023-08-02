class AddMetaDataPowerUsersGroupIdSetting < ActiveRecord::Migration[6.1]
  def change
    add_column(:app_settings, :edit_meta_data_power_users_group_id, :uuid)
    add_foreign_key(:app_settings, :groups, column: :edit_meta_data_power_users_group_id)
  end
end
