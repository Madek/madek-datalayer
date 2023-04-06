CREATE TABLE public.user_sessions (
    id uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
    auth_system_id text NOT NULL,
    meta_data jsonb,
    token_hash text UNIQUE NOT NULL,
    token_part text NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now(), 
    CONSTRAINT fk_auth_system FOREIGN KEY (auth_system_id)
      REFERENCES auth_systems(id) ON DELETE CASCADE,
    CONSTRAINT fk_user FOREIGN KEY(user_id) 
      REFERENCES users(id) ON DELETE CASCADE);

CREATE INDEX idx_user_sessions_on_created_at ON user_sessions (created_at);


CREATE FUNCTION user_sessions_clean_expired() RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM user_sessions
    USING auth_systems
    WHERE user_sessions.auth_system_id = auth_systems.id
    AND user_sessions.user_id = NEW.user_id
    AND (user_sessions.created_at + auth_systems.session_max_lifetime_minutes * interval '1 minute') < now();
  RETURN NULL;
END
$$;

COMMENT ON FUNCTION user_sessions_clean_expired 
  IS 'Delete expired sessions on INSERT for same user (audits) only';


CREATE TRIGGER user_sessions_clean_expired 
  AFTER INSERT ON user_sessions FOR EACH ROW 
  EXECUTE FUNCTION user_sessions_clean_expired();

