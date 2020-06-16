class AddAppTimezoneToAppSettings < ActiveRecord::Migration[4.2]
  def change
    add_column :app_settings, :time_zone, :string, default: 'Europe/Zurich', null: false
  end
end
