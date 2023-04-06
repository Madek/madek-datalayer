--- auth systems --------------------------------------------------------------

CREATE TABLE public.auth_systems (
    id character varying PRIMARY KEY,
    create_account_email_match text,
    create_account_enabled boolean DEFAULT false NOT NULL,
    description text,
    session_max_lifetime_minutes int DEFAULT (60 * 18) NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    external_public_key text,
    external_sign_in_url text,
    external_sign_out_url text,
    internal_private_key text,
    internal_public_key text,
    name character varying NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    send_email boolean DEFAULT true NOT NULL,
    send_login boolean DEFAULT false NOT NULL,
    send_org_id boolean DEFAULT false NOT NULL,
    type text DEFAULT 'external' NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT simple_id CHECK (((id)::text ~ '^[a-z][a-z0-9_-]*$'::text)),
    CONSTRAINT allowed_type CHECK (type IN ('password', 'external')),
    CONSTRAINT password_special
      CHECK ((type = 'external' AND id <> 'password') 
        OR (type = 'password' AND id = 'password'))
    );

CREATE TRIGGER update_updated_at_column_of_auth_systems 
  BEFORE UPDATE ON public.auth_systems 
  FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) 
    EXECUTE PROCEDURE public.update_updated_at_column();

INSERT INTO auth_systems 
  (id, type, name) VALUES ('password', 'password', 'Madek Password Authentication');


--- users ---------------------------------------------------------------------

CREATE TABLE public.auth_systems_users (
    id uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
    auth_system_id character varying NOT NULL,
    data text,
    user_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT fk_auth_sys FOREIGN KEY(auth_system_id) 
      REFERENCES auth_systems(id) ON DELETE CASCADE,
    CONSTRAINT fk_user FOREIGN KEY(user_id) 
      REFERENCES users(id) ON DELETE CASCADE);

CREATE UNIQUE INDEX idx_auth_sys_users 
  ON public.auth_systems_users 
  USING btree (user_id, auth_system_id);

CREATE INDEX idx_auth_systems_users_on_auth_system_id 
  ON public.auth_systems_users (auth_system_id);

CREATE INDEX idx_auth_system_users_on_user_id 
  ON public.auth_systems_users (user_id);

CREATE TRIGGER update_updated_at_column_of_auth_systems_users 
  BEFORE UPDATE ON public.auth_systems_users 
  FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) 
    EXECUTE PROCEDURE public.update_updated_at_column();




--- groups --------------------------------------------------------------------

CREATE TABLE public.auth_systems_groups (
    id uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
    group_id uuid NOT NULL,
    auth_system_id character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT fk_auth_sys FOREIGN KEY(auth_system_id) 
      REFERENCES auth_systems(id) ON DELETE CASCADE,
    CONSTRAINT fk_group FOREIGN KEY(group_id) 
      REFERENCES groups(id) ON DELETE CASCADE);

CREATE UNIQUE INDEX idx_auth_sys_groups 
  ON public.auth_systems_groups USING 
  btree (group_id, auth_system_id);

CREATE INDEX index_auth_systems_groups_on_auth_system_id 
  ON public.auth_systems_groups (auth_system_id);

CREATE INDEX index_auth_systems_groups_on_group_id 
  ON public.auth_systems_groups (group_id);

CREATE TRIGGER update_updated_at_column_of_auth_systems_groups 
  BEFORE UPDATE ON public.auth_systems_groups 
  FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) 
    EXECUTE PROCEDURE public.update_updated_at_column();
