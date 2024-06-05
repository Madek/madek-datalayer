class AddEmailsLocaleToUsers < ActiveRecord::Migration[6.1]
  include Madek::MigrationHelper

  def change
    change_column_null :app_settings, :default_locale, false
    change_column_null :app_settings, :available_locales, false
    add_column :users, :emails_locale, :string
  end
end
