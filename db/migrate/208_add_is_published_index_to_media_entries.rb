class AddIsPublishedIndexToMediaEntries < ActiveRecord::Migration
  def change
    add_index :media_entries, :is_published
  end
end
