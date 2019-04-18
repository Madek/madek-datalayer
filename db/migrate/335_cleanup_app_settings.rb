class CleanupAppSettings < ActiveRecord::Migration[4.2]

  class ::MigrationAppSetting < ActiveRecord::Base
    self.table_name = 'app_settings'
  end

  class ::MigrationContext < ActiveRecord::Base
    self.table_name = 'contexts'
  end


  def up
    change_column :app_settings, :brand_logo_url, :string, null: true, default: nil
    change_column :app_settings, :catalog_context_keys, :text, array: true, null: false, default: []

    MigrationAppSetting.attribute_names.select {|k| k.starts_with?('context_')}.each do |k|
      change_column :app_settings, k, :text, null: true, default: nil
    end

    MigrationAppSetting.attribute_names.select {|k| k.starts_with?('contexts_')}.each do |k|
      change_column :app_settings, k, :text, array: true, null: false, default: []
    end
    MigrationAppSetting.reset_column_information

    # delete invalid contexts from configs
    settings = MigrationAppSetting.first
    settings.attribute_names.select {|key| key.starts_with? 'context'}.each do |key|
      settings.update_attributes!(key => clean_context_ids(settings[key]))
    end
  end

  private

  def clean_context_ids(list_or_id)
    if list_or_id.is_a?(Array)
      list_or_id.select { |cid| clean_context_ids(cid) }
    else
      MigrationContext.find_by(id: list_or_id).try(:id)
    end
  end
end
