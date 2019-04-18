class MigrateToAuthenticationGroups < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL.strip_heredoc
      UPDATE groups SET type = 'AuthenticationGroup'
        WHERE name = 'ZHdK (Zürcher Hochschule der Künste)';
    SQL
  end
end
