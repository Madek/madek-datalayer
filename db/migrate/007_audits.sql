CREATE FUNCTION public.txid() RETURNS uuid
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN public.uuid_generate_v5(public.uuid_nil(), current_date::TEXT || ' ' || txid_current()::TEXT);
END;
$$;



CREATE TABLE public.audited_changes (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    txid uuid DEFAULT public.txid() NOT NULL,
    tg_op text NOT NULL,
    table_name text NOT NULL,
    changed jsonb,
    created_at timestamp with time zone DEFAULT now(),
    pkey text
);

ALTER TABLE ONLY public.audited_changes ADD CONSTRAINT audited_changes_pkey PRIMARY KEY (id);
CREATE INDEX audited_changes_changed_idx ON public.audited_changes USING gin (to_tsvector('english'::regconfig, changed));
CREATE INDEX audited_changes_table_name ON public.audited_changes USING btree (table_name);
CREATE INDEX audited_changes_tg_op ON public.audited_changes USING btree (tg_op);
CREATE INDEX audited_changes_txid ON public.audited_changes USING btree (txid);


CREATE TABLE public.audited_requests (
    txid uuid DEFAULT public.txid() NOT NULL,
    user_id uuid,
    path text,
    method text,
    created_at timestamp with time zone DEFAULT now(),
    http_uid text,
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    CONSTRAINT check_absolute_path CHECK ((path ~ '^/.*$'::text))
);

ALTER TABLE ONLY public.audited_requests ADD CONSTRAINT audited_requests_pkey PRIMARY KEY (id);
CREATE INDEX audited_requests_created_at ON public.audited_requests USING btree (created_at);
CREATE INDEX audited_requests_method ON public.audited_requests USING btree (method);
CREATE INDEX audited_requests_txid ON public.audited_requests USING btree (txid);
CREATE INDEX audited_requests_url ON public.audited_requests USING btree (path);
CREATE INDEX audited_requests_user_id ON public.audited_requests USING btree (user_id);

-------------------------------------------------------------------------------


CREATE TABLE public.audited_responses (
    txid uuid NOT NULL,
    status integer NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tx2id uuid
);


ALTER TABLE ONLY public.audited_responses ADD CONSTRAINT audited_responses_pkey PRIMARY KEY (id);
CREATE INDEX audited_responses_created_at ON public.audited_responses USING btree (created_at);
CREATE INDEX audited_responses_status ON public.audited_responses USING btree (status);
CREATE INDEX audited_responses_tx2id ON public.audited_responses USING btree (tx2id);
CREATE INDEX audited_responses_txid ON public.audited_responses USING btree (txid);


-------------------------------------------------------------------------------


CREATE FUNCTION public.jsonb_changed(jold jsonb, jnew jsonb) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
  result JSONB := '{}'::JSONB;
  k TEXT;
  v_new JSONB;
  v_old JSONB;
BEGIN
  FOR k IN SELECT * FROM jsonb_object_keys(jold || jnew) LOOP
    if jnew ? k
      THEN v_new := jnew -> k;
      ELSE v_new := 'null'::JSONB; END IF;
    if jold ? k
      THEN v_old := jold -> k;
      ELSE v_old := 'null'::JSONB; END IF;
    IF k = 'updated_at' THEN CONTINUE; END IF;
    IF v_new = v_old THEN CONTINUE; END IF;
    result := result || jsonb_build_object(k, jsonb_build_array(v_old, v_new));
  END LOOP;
  RETURN result;
END;
$$;


CREATE FUNCTION public.audit_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  DECLARE
    changed JSONB;
    j_new JSONB := '{}'::JSONB;
    j_old JSONB := '{}'::JSONB;
    pkey TEXT;
    pkey_col TEXT := (
                SELECT attname
                FROM pg_index
                JOIN pg_attribute ON
                    attrelid = indrelid
                    AND attnum = ANY(indkey)
                WHERE indrelid = TG_RELID AND indisprimary);
BEGIN
  IF (TG_OP = 'DELETE') THEN
    j_old := row_to_json(OLD)::JSONB;
    pkey := j_old ->> pkey_col;
  ELSIF (TG_OP = 'INSERT') THEN
    j_new := row_to_json(NEW)::JSONB;
    pkey := j_new ->> pkey_col;
  ELSIF (TG_OP = 'UPDATE') THEN
    j_old := row_to_json(OLD)::JSONB;
    j_new := row_to_json(NEW)::JSONB;
    pkey := j_old ->> pkey_col;
  END IF;
  changed := public.jsonb_changed(j_old, j_new);
  if ( changed <> '{}'::JSONB ) THEN
    INSERT INTO public.audited_changes (tg_op, table_name, changed, pkey)
      VALUES (TG_OP, TG_TABLE_NAME, changed, pkey);
  END IF;
  RETURN NEW;
END;
$$;




--CREATE TRIGGER audited_change_on_api_tokens AFTER INSERT OR DELETE OR UPDATE ON public.api_tokens FOR EACH ROW EXECUTE FUNCTION public.audit_change();
--CREATE TRIGGER audited_change_on_api_tokens AFTER INSERT OR DELETE OR UPDATE ON public.api_tokens FOR EACH ROW EXECUTE FUNCTION public.audit_change();
