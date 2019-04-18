class AddIndexesToNewUpdatedAtCols < ActiveRecord::Migration[4.2]
  def change
    %w(media_entries collections filter_sets).each do |table_name|
      add_index table_name, :edit_session_updated_at
      add_index table_name, :meta_data_updated_at
    end
  end
end
