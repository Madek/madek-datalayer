--
-- Name: base32_crockford_str(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.base32_crockford_str(n integer DEFAULT 10) RETURNS text
LANGUAGE sql
AS $$
    SELECT
      string_agg(substr(characters, (random() * length(characters) + 1)::integer, 1), '')
    FROM (values('0123456789ABCDEFGHJKMNPQRSTVWXYZ')) as symbols(characters)
      JOIN generate_series(1, n) on 1 = 1;
    $$;


--
-- Name: user_password_resets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_password_resets (
  id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
  user_id uuid NOT NULL,
  used_user_param text NOT NULL,
  token text DEFAULT public.base32_crockford_str(20) NOT NULL,
  valid_until timestamp without time zone NOT NULL,
  created_at timestamp without time zone DEFAULT now() NOT NULL,
  CONSTRAINT check_token_base32_crockford CHECK ((token ~ '^[0123456789ABCDEFGHJKMNPQRSTVWXYZ]+$'::text))
);

--
-- name: user_password_resets user_password_resets_pkey; type: constraint; schema: public; owner: -
--

ALTER TABLE ONLY public.user_password_resets
ADD CONSTRAINT user_password_resets_pkey primary key (id);

--
-- Name: user_password_resets fk_rails_c84bfcc8b6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_password_resets
ADD CONSTRAINT user_password_resets_users_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- name: index_user_password_resets_on_user_id; type: index; schema: public; owner: -
--

CREATE UNIQUE INDEX index_user_password_resets_on_user_id ON public.user_password_resets USING btree (user_id);


-- Name: delete_obsolete_user_password_resets_1(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_obsolete_user_password_resets_1() RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM user_password_resets
  WHERE user_id = NEW.user_id;

  RETURN NEW;
END;
$$;


--
-- Name: delete_obsolete_user_password_resets_2(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_obsolete_user_password_resets_2() RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.auth_system_id = 'password' THEN
    DELETE FROM user_password_resets
    WHERE user_id = NEW.user_id;
  END IF;

  RETURN NEW;
END;
$$;


-- Name: auth_systems_users trigger_delete_obsolete_user_password_resets; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_delete_obsolete_user_password_resets
AFTER INSERT OR UPDATE ON public.auth_systems_users
FOR EACH ROW EXECUTE FUNCTION public.delete_obsolete_user_password_resets_2();


--
-- Name: user_password_resets trigger_delete_obsolete_user_password_resets; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_delete_obsolete_user_password_resets
BEFORE INSERT ON public.user_password_resets
FOR EACH ROW EXECUTE FUNCTION public.delete_obsolete_user_password_resets_1();


--
-- Name: user_password_resets audited_change_on_user_password_resets; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER audited_change_on_user_password_resets
AFTER INSERT OR DELETE OR UPDATE ON public.user_password_resets
FOR EACH ROW EXECUTE FUNCTION public.audit_change();

