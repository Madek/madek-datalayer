class AddIndexesToFilterableColumnsForMediaFiles < ActiveRecord::Migration
  def change
    add_index :zencoder_jobs, :request
    add_index :zencoder_jobs, :state
    add_index :media_files, :filename
  end
end
