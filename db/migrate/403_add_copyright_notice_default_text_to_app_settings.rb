class AddCopyrightNoticeDefaultTextToAppSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :app_settings, :copyright_notice_default_text, :string
  end
end
