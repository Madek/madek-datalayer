class SessionLifetimeHours < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL.strip_heredoc
      ALTER TABLE auth_systems DROP COLUMN session_max_lifetime_minutes;
      ALTER TABLE auth_systems ADD COLUMN session_max_lifetime_hours float CHECK (session_max_lifetime_hours >= 0) DEFAULT 15;

      CREATE OR REPLACE FUNCTION user_sessions_clean_expired() RETURNS trigger
      LANGUAGE plpgsql
      AS $$
      BEGIN
        DELETE FROM user_sessions
          USING auth_systems
          WHERE user_sessions.auth_system_id = auth_systems.id
          AND user_sessions.user_id = NEW.user_id
          AND (user_sessions.created_at + auth_systems.session_max_lifetime_hours * interval '1 hour') < now();
        RETURN NULL;
      END
      $$;


    SQL
  end
end
