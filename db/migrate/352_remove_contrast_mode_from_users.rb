class RemoveContrastModeFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :contrast_mode, :boolean
  end
end
