class RemoveContrastModeFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :contrast_mode, :boolean
  end
end
