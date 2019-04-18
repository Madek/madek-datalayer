class AddForeignKeysToMediaFiles < ActiveRecord::Migration[4.2]
  def change
    add_foreign_key :media_files, :users, column: :uploader_id
  end
end
