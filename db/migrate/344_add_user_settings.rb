class AddUserSettings < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL.strip_heredoc
      ALTER TABLE users ADD COLUMN settings jsonb DEFAULT '{}' NOT NULL
    SQL
  end
end
