class AddContraintsForUserSignInColumns < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL.strip_heredoc
      UPDATE users SET email = NULL WHERE email ~ '^\\s*$';

      CREATE UNIQUE INDEX unique_email_idx ON users (lower(email));

      CREATE UNIQUE INDEX unique_login_idx ON users (login);

      ALTER TABLE users ADD CONSTRAINT email_format CHECK ((email ~ '\\S+@\\S+') OR (email IS NULL));

      -- we can't enfoce this currently with ZHdK data; login AND email may be reused and must be reset
      -- to NULL possibly
      -- ALTER TABLE users ADD CONSTRAINT either_login_or_email_present CHECK ((email IS NOT NULL) OR (login IS NOT NULL));
    SQL
  end
end
