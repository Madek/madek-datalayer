class AddNullRestrictionToUploaderId < ActiveRecord::Migration[4.2]
  def change
    change_column :media_files, :uploader_id, :uuid, null: false
  end
end
