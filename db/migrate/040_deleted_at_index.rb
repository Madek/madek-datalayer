class DeletedAtIndex < ActiveRecord::Migration[6.1]

  def change
    add_index(:collections, :deleted_at)
    add_index(:media_entries, :deleted_at)
  end

end
