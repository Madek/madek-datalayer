class AddUploaderIdToMediaFiles < ActiveRecord::Migration[4.2]
  def change
    add_column :media_files, :uploader_id, :uuid, index: true
  end
end
