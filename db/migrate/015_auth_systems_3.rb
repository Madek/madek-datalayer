class AuthSystems3 < ActiveRecord::Migration[6.0]
  def up

    execute <<-SQL.strip_heredoc

      UPDATE auth_systems SET name = 'Login für externe Personen' WHERE id = 'password';
      UPDATE auth_systems SET name = 'ZHdK-Login' WHERE id = 'zhdk_agw';

      SQL

  end


  def down
  end

end

