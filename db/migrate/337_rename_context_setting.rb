class RenameContextSetting < ActiveRecord::Migration

  def change
    rename_column(:app_settings,
      :contexts_for_validation, :contexts_for_entry_validation)
  end

end