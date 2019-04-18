class AddIsPublishedIndexToMediaEntries < ActiveRecord::Migration[4.2]
  def change
    add_index :media_entries, :is_published
  end
end
