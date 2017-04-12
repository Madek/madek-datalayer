class AddUserSettings < ActiveRecord::Migration
  def change
    execute <<-SQL.strip_heredoc
      ALTER TABLE users ADD COLUMN settings jsonb DEFAULT '{}' NOT NULL
    SQL
  end
end
