class AddAboutPageToAppSetting < ActiveRecord::Migration[4.2]
  class MigrationAppSetting < ActiveRecord::Base
    self.table_name = :app_settings
  end

  def change
    add_column :app_settings, :about_page, :string, default: ''
  end
end
