class InsertIntoSmtpSettings < ActiveRecord::Migration[6.1]
  class MigrateSmtpSetting < ActiveRecord::Base
    self.table_name = 'smtp_settings'
  end

  def up
    MigrateSmtpSetting.create!
  end

  def down
    MigrateSmtpSetting.delete_all
  end
end
