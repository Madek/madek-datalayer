class RemoveUpdatedAtFromEditSessions < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL.strip_heredoc
      DROP TRIGGER update_updated_at_column_of_edit_sessions ON edit_sessions;
      ALTER TABLE edit_sessions DROP COLUMN updated_at CASCADE;
    SQL
  end
end
