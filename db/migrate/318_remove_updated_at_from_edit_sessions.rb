class RemoveUpdatedAtFromEditSessions < ActiveRecord::Migration
  def change
    execute <<-SQL.strip_heredoc
      ALTER TABLE edit_sessions DROP COLUMN updated_at CASCADE;
    SQL
  end
end
