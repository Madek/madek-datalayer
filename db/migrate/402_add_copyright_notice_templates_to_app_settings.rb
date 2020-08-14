class AddCopyrightNoticeTemplatesToAppSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :app_settings, :copyright_notice_templates, :text, array: true, default: []
    add_index :app_settings, :copyright_notice_templates, using: "gin"
  end
end
