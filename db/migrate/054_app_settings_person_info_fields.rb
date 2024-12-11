class AppSettingsPersonInfoFields < ActiveRecord::Migration[6.1]
  def change
    add_column :app_settings, :person_info_fields, :text, array: true, null: false, default: ['identification_info']
  end
end
