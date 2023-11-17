class InsertIntoSmtpSettings < ActiveRecord::Migration[6.1]
  class MigrateSmtpSetting < ActiveRecord::Base
    self.table_name = 'smtp_settings'
  end

  def up
    MigrateSmtpSetting.create!

    change_column(:smtp_settings, :created_at, :timestamptz, null: false)
    change_column(:smtp_settings, :updated_at, :timestamptz, null: false)
  end

  def down
    change_column(:smtp_settings, :created_at, :timestamptz, null: true)
    change_column(:smtp_settings, :updated_at, :timestamptz, null: true)

    MigrateSmtpSetting.delete_all
  end
end
