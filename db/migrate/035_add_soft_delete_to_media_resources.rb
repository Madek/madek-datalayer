class AddSoftDeleteToMediaResources < ActiveRecord::Migration[6.1]
  def change
    [:media_entries, :collections].each do |table|
      add_column table, :deleted_at, "timestamp with time zone"
    end
  end
end
