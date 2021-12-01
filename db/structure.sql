SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: collection_layout; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.collection_layout AS ENUM (
    'grid',
    'list',
    'miniature',
    'tiles'
);


--
-- Name: collection_sorting; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.collection_sorting AS ENUM (
    'created_at ASC',
    'created_at DESC',
    'title ASC',
    'title DESC',
    'last_change',
    'manual ASC',
    'manual DESC'
);


--
-- Name: check_collection_cover_uniqueness(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_collection_cover_uniqueness() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
          BEGIN
            IF
              (SELECT
                (SELECT COUNT(1)
                 FROM collection_media_entry_arcs
                 WHERE collection_media_entry_arcs.cover IS true
                 AND collection_media_entry_arcs.collection_id = NEW.collection_id)
              > 1)
              THEN RAISE EXCEPTION 'There exists already a cover for collection %.', NEW.collection_id;
            END IF;
            RETURN NEW;
          END;
          $$;


--
-- Name: check_collection_primary_uniqueness(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_collection_primary_uniqueness() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          IF
            (SELECT
              (SELECT COUNT(1)
               FROM custom_urls
               WHERE custom_urls.is_primary IS true
               AND custom_urls.collection_id = NEW.collection_id)
            > 1)
            THEN RAISE EXCEPTION 'There exists already a primary id for collection %.', NEW.collection_id;
          END IF;
          RETURN NEW;
        END;
        $$;


--
-- Name: check_filter_set_primary_uniqueness(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_filter_set_primary_uniqueness() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          IF
            (SELECT
              (SELECT COUNT(1)
               FROM custom_urls
               WHERE custom_urls.is_primary IS true
               AND custom_urls.filter_set_id = NEW.filter_set_id)
            > 1)
            THEN RAISE EXCEPTION 'There exists already a primary id for filter_set %.', NEW.filter_set_id;
          END IF;
          RETURN NEW;
        END;
        $$;


--
-- Name: check_madek_core_meta_key_immutability(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_madek_core_meta_key_immutability() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
          BEGIN
            IF (TG_OP = 'DELETE') THEN
              IF (OLD.id ilike 'madek_core:%') THEN
                RAISE EXCEPTION 'The madek_core meta_key % may not be deleted', OLD.id;
              END IF;
            ELSIF  (TG_OP = 'UPDATE') THEN
              IF (OLD.id ilike 'madek_core:%') THEN
                RAISE EXCEPTION 'The madek_core meta_key % may not be modified', OLD.id;
              END IF;
              IF (NEW.id ilike 'madek_core:%') THEN
                RAISE EXCEPTION 'The madek_core meta_key namespace may not be extended by %', NEW.id;
              END IF;
            ELSIF  (TG_OP = 'INSERT') THEN
              IF (NEW.id ilike 'madek_core:%') THEN
                RAISE EXCEPTION 'The madek_core meta_key namespace may not be extended by %', NEW.id;
              END IF;
            END IF;
            RETURN NEW;
          END;
          $$;


--
-- Name: check_media_entry_primary_uniqueness(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_media_entry_primary_uniqueness() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          IF
            (SELECT
              (SELECT COUNT(1)
               FROM custom_urls
               WHERE custom_urls.is_primary IS true
               AND custom_urls.media_entry_id = NEW.media_entry_id)
            > 1)
            THEN RAISE EXCEPTION 'There exists already a primary id for media_entry %.', NEW.media_entry_id;
          END IF;
          RETURN NEW;
        END;
        $$;


--
-- Name: check_meta_data_created_by(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_meta_data_created_by() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.created_by_id IS NULL THEN
    RAISE EXCEPTION 'created_by in table meta_data may not be null';
  END IF;
  RETURN NEW;
END;
$$;


--
-- Name: check_meta_data_keywords_created_by(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_meta_data_keywords_created_by() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.created_by_id IS NULL THEN
    RAISE EXCEPTION 'created_by in table meta_data_keywords may not be null';
  END IF;
  RETURN NEW;
END;
$$;


--
-- Name: check_meta_data_licenses_created_by(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_meta_data_licenses_created_by() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.created_by_id IS NULL THEN
    RAISE EXCEPTION 'created_by in table meta_data_licenses may not be null';
  END IF;
  RETURN NEW;
END;
$$;


--
-- Name: check_meta_data_meta_key_type_consistency(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_meta_data_meta_key_type_consistency() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
          BEGIN

            IF EXISTS (SELECT 1 FROM meta_keys 
              JOIN meta_data ON meta_data.meta_key_id = meta_keys.id
              WHERE meta_data.id = NEW.id
              AND meta_keys.meta_datum_object_type <> meta_data.type) THEN
                RAISE EXCEPTION 'The types of related meta_data and meta_keys must be identical';
            END IF;

            RETURN NEW;
          END;
          $$;


--
-- Name: check_meta_data_people_created_by(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_meta_data_people_created_by() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.created_by_id IS NULL THEN
    RAISE EXCEPTION 'created_by in table meta_data_people may not be null';
  END IF;
  RETURN NEW;
END;
$$;


--
-- Name: check_meta_key_id_consistency_for_keywords(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_meta_key_id_consistency_for_keywords() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
          BEGIN

            IF (SELECT meta_key_id
                FROM meta_data
                WHERE meta_data.id = NEW.meta_datum_id) <>
               (SELECT meta_key_id
                FROM keywords
                WHERE id = NEW.keyword_id)
            THEN
                RAISE EXCEPTION 'The meta_key_id for meta_data and keywords must be identical';
            END IF;

            RETURN NEW;
          END;
          $$;


--
-- Name: check_meta_key_meta_data_type_consistency(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_meta_key_meta_data_type_consistency() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
          BEGIN

            IF EXISTS (SELECT 1 FROM meta_keys 
              JOIN meta_data ON meta_data.meta_key_id = meta_keys.id
              WHERE meta_keys.id = NEW.id
              AND meta_keys.meta_datum_object_type <> meta_data.type) THEN
                RAISE EXCEPTION 'The types of related meta_data and meta_keys must be identical';
            END IF;

            RETURN NEW;
          END;
          $$;


--
-- Name: check_no_drafts_in_collections(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_no_drafts_in_collections() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        IF
          (SELECT is_published FROM media_entries WHERE id = NEW.media_entry_id) = false
          AND NOT EXISTS (
            SELECT 1 FROM workflows WHERE workflows.is_active = TRUE AND workflows.id IN (
              SELECT workflow_id FROM collections WHERE collections.id IN (
                WITH RECURSIVE parent_ids as (
  SELECT parent_id
  FROM collection_collection_arcs
  WHERE child_id IN (
    SELECT collection_id
    FROM collection_media_entry_arcs
    WHERE media_entry_id = NEW.media_entry_id
  )
  UNION
    SELECT cca.parent_id
    FROM collection_collection_arcs cca
    JOIN parent_ids p ON cca.child_id = p.parent_id
)
SELECT parent_id FROM parent_ids
UNION
  SELECT cmea.collection_id
  FROM collection_media_entry_arcs cmea
  WHERE media_entry_id = NEW.media_entry_id

              )
            )
          )
          THEN RAISE EXCEPTION 'Incomplete MediaEntries can not be put into Collections!';
        END IF;
        RETURN NEW;
      END;
      $$;


--
-- Name: check_users_apiclients_login_uniqueness(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_users_apiclients_login_uniqueness() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        IF (EXISTS (SELECT 1 FROM users, api_clients
              WHERE api_clients.login = users.login
              AND api_clients.login = NEW.login)) THEN
          RAISE EXCEPTION 'The login % over users and api_clients must be unique.', NEW.login;
        END IF;
        RETURN NEW;
      END;
      $$;


--
-- Name: collection_may_not_be_its_own_parent(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.collection_may_not_be_its_own_parent() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
          BEGIN
            IF
              (SELECT
                (SELECT COUNT(1)
                 FROM collection_collection_arcs
                 WHERE NEW.parent_id = NEW.child_id
                )
              > 0)
              THEN RAISE EXCEPTION 'Collection may not be its own parent %.', NEW.collection_id;
            END IF;
            RETURN NEW;
          END;
          $$;


--
-- Name: delete_empty_group_after_delete_join(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_empty_group_after_delete_join() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
          BEGIN
            IF (EXISTS (SELECT 1 FROM groups WHERE groups.id = OLD.group_id)
                AND NOT EXISTS ( SELECT 1
                                 FROM groups_users
                                 JOIN groups ON groups.id = groups_users.group_id
                                 WHERE groups.id = OLD.group_id))
            THEN
              DELETE FROM groups WHERE groups.id = OLD.group_id;
            END IF;
            RETURN NEW;
          END;
          $$;


--
-- Name: delete_empty_meta_data_groups_after_delete_join(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_empty_meta_data_groups_after_delete_join() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
                    BEGIN
                      IF (EXISTS (SELECT 1 FROM meta_data WHERE meta_data.id = OLD.meta_datum_id)
                          AND NOT EXISTS ( SELECT 1 FROM meta_data
                                            JOIN  meta_data_groups ON meta_data.id = meta_data_groups.meta_datum_id
                                            WHERE meta_data.id = OLD.meta_datum_id)
                            ) THEN
                        DELETE FROM meta_data WHERE meta_data.id = OLD.meta_datum_id;
                      END IF;
                      RETURN NEW;
                    END;
                    $$;


--
-- Name: delete_empty_meta_data_groups_after_insert(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_empty_meta_data_groups_after_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
                    BEGIN
                      IF ( NOT EXISTS ( SELECT 1 FROM meta_data
                                            JOIN meta_data_groups ON meta_data.id = meta_data_groups.meta_datum_id
                                            WHERE meta_data.id = NEW.id)) THEN
                        DELETE FROM meta_data WHERE meta_data.id = NEW.id;
                      END IF;
                      RETURN NEW;
                    END;
                    $$;


--
-- Name: delete_empty_meta_data_keywords_after_delete_join(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_empty_meta_data_keywords_after_delete_join() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
                    BEGIN
                      IF (EXISTS (SELECT 1 FROM meta_data WHERE meta_data.id = OLD.meta_datum_id)
                          AND NOT EXISTS ( SELECT 1 FROM meta_data
                                            JOIN  meta_data_keywords ON meta_data.id = meta_data_keywords.meta_datum_id
                                            WHERE meta_data.id = OLD.meta_datum_id)
                            ) THEN
                        DELETE FROM meta_data WHERE meta_data.id = OLD.meta_datum_id;
                      END IF;
                      RETURN NEW;
                    END;
                    $$;


--
-- Name: delete_empty_meta_data_keywords_after_insert(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_empty_meta_data_keywords_after_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
                    BEGIN
                      IF ( NOT EXISTS ( SELECT 1 FROM meta_data
                                            JOIN meta_data_keywords ON meta_data.id = meta_data_keywords.meta_datum_id
                                            WHERE meta_data.id = NEW.id)) THEN
                        DELETE FROM meta_data WHERE meta_data.id = NEW.id;
                      END IF;
                      RETURN NEW;
                    END;
                    $$;


--
-- Name: delete_empty_meta_data_licenses_after_delete_join(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_empty_meta_data_licenses_after_delete_join() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
                    BEGIN
                      IF (EXISTS (SELECT 1 FROM meta_data WHERE meta_data.id = OLD.meta_datum_id)
                          AND NOT EXISTS ( SELECT 1 FROM meta_data
                                            JOIN  meta_data_licenses ON meta_data.id = meta_data_licenses.meta_datum_id
                                            WHERE meta_data.id = OLD.meta_datum_id)
                            ) THEN
                        DELETE FROM meta_data WHERE meta_data.id = OLD.meta_datum_id;
                      END IF;
                      RETURN NEW;
                    END;
                    $$;


--
-- Name: delete_empty_meta_data_licenses_after_insert(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_empty_meta_data_licenses_after_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
                    BEGIN
                      IF ( NOT EXISTS ( SELECT 1 FROM meta_data
                                            JOIN meta_data_licenses ON meta_data.id = meta_data_licenses.meta_datum_id
                                            WHERE meta_data.id = NEW.id)) THEN
                        DELETE FROM meta_data WHERE meta_data.id = NEW.id;
                      END IF;
                      RETURN NEW;
                    END;
                    $$;


--
-- Name: delete_empty_meta_data_people_after_delete_join(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_empty_meta_data_people_after_delete_join() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
                    BEGIN
                      IF (EXISTS (SELECT 1 FROM meta_data WHERE meta_data.id = OLD.meta_datum_id)
                          AND NOT EXISTS ( SELECT 1 FROM meta_data
                                            JOIN  meta_data_people ON meta_data.id = meta_data_people.meta_datum_id
                                            WHERE meta_data.id = OLD.meta_datum_id)
                            ) THEN
                        DELETE FROM meta_data WHERE meta_data.id = OLD.meta_datum_id;
                      END IF;
                      RETURN NEW;
                    END;
                    $$;


--
-- Name: delete_empty_meta_data_people_after_insert(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_empty_meta_data_people_after_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
                    BEGIN
                      IF ( NOT EXISTS ( SELECT 1 FROM meta_data
                                            JOIN meta_data_people ON meta_data.id = meta_data_people.meta_datum_id
                                            WHERE meta_data.id = NEW.id)) THEN
                        DELETE FROM meta_data WHERE meta_data.id = NEW.id;
                      END IF;
                      RETURN NEW;
                    END;
                    $$;


--
-- Name: delete_meta_datum_text_string_null(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_meta_datum_text_string_null() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
          BEGIN
            IF ((NEW.type = 'MetaDatum::Text' OR NEW.type = 'MetaDatum::TextDate')
                AND NEW.string IS NULL) THEN
              DELETE FROM meta_data WHERE meta_data.id = NEW.id;
            END IF;
            RETURN NEW;
          END;
          $$;


--
-- Name: groups_update_searchable_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.groups_update_searchable_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   NEW.searchable = COALESCE(NEW.name::text, '') || ' ' || COALESCE(NEW.institutional_name::text, '') ;
   RETURN NEW;
END;
$$;


--
-- Name: licenses_update_searchable_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.licenses_update_searchable_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   NEW.searchable = COALESCE(NEW.label::text, '') || ' ' || COALESCE(NEW.usage::text, '') || ' ' || COALESCE(NEW.url::text, '') ;
   RETURN NEW;
END;
$$;


--
-- Name: people_update_searchable_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.people_update_searchable_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   NEW.searchable = COALESCE(NEW.first_name::text, '') || ' ' || COALESCE(NEW.last_name::text, '') || ' ' || COALESCE(NEW.pseudonym::text, '') ;
   RETURN NEW;
END;
$$;


--
-- Name: person_display_name(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.person_display_name(first_name character varying, last_name character varying, pseudonym character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
        BEGIN RETURN (CASE
                          WHEN ((first_name <> ''
                                 OR last_name <> '')
                                AND pseudonym <> '') THEN btrim(first_name || ' ' || last_name || ' ' || '(' || pseudonym || ')')
                          WHEN (first_name <> ''
                                OR last_name <> '') THEN btrim(first_name || ' ' || last_name)
                          ELSE btrim(pseudonym)
                      END);
        END;
      $$;


--
-- Name: propagate_edit_session_insert_to_collections(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.propagate_edit_session_insert_to_collections() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE collections SET edit_session_updated_at = now()
    FROM edit_sessions
    WHERE edit_sessions.id = NEW.id
    AND collections.id = edit_sessions.collection_id;
  RETURN NULL;
END;
$$;


--
-- Name: propagate_edit_session_insert_to_filter_sets(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.propagate_edit_session_insert_to_filter_sets() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE filter_sets SET edit_session_updated_at = now()
    FROM edit_sessions
    WHERE edit_sessions.id = NEW.id
    AND filter_sets.id = edit_sessions.filter_set_id;
  RETURN NULL;
END;
$$;


--
-- Name: propagate_edit_session_insert_to_media_entries(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.propagate_edit_session_insert_to_media_entries() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE media_entries SET edit_session_updated_at = now()
    FROM edit_sessions
    WHERE edit_sessions.id = NEW.id
    AND media_entries.id = edit_sessions.media_entry_id;
  RETURN NULL;
END;
$$;


--
-- Name: propagate_keyword_updates_to_meta_data_keywords(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.propagate_keyword_updates_to_meta_data_keywords() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE meta_data_keywords
    SET meta_data_updated_at = now()
    WHERE keyword_id = NEW.id;
  RETURN NULL;
END;
$$;


--
-- Name: propagate_license_updates_to_meta_data_licenses(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.propagate_license_updates_to_meta_data_licenses() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE meta_data_licenses
    SET meta_data_updated_at = now()
    WHERE license_id = NEW.id;
  RETURN NULL;
END;
$$;


--
-- Name: propagate_meta_data_keyword_updates_to_meta_data(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.propagate_meta_data_keyword_updates_to_meta_data() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  md_id UUID;
BEGIN
  CASE
    WHEN TG_OP = 'DELETE' THEN
      md_id = OLD.meta_datum_id;
    ELSE
      md_id = NEW.meta_datum_id;
  END CASE;

  UPDATE meta_data
    SET meta_data_updated_at = now()
    WHERE meta_data.id = md_id;
  RETURN NULL;
END;
$$;


--
-- Name: propagate_meta_data_license_updates_to_meta_data(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.propagate_meta_data_license_updates_to_meta_data() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  md_id UUID;
BEGIN
  CASE
    WHEN TG_OP = 'DELETE' THEN
      md_id = OLD.meta_datum_id;
    ELSE
      md_id = NEW.meta_datum_id;
  END CASE;

  UPDATE meta_data
    SET meta_data_updated_at = now()
    WHERE meta_data.id = md_id;
  RETURN NULL;
END;
$$;


--
-- Name: propagate_meta_data_people_updates_to_meta_data(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.propagate_meta_data_people_updates_to_meta_data() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  md_id UUID;
BEGIN
  CASE
    WHEN TG_OP = 'DELETE' THEN
      md_id = OLD.meta_datum_id;
    ELSE
      md_id = NEW.meta_datum_id;
  END CASE;

  UPDATE meta_data
    SET meta_data_updated_at = now()
    WHERE meta_data.id = md_id;
  RETURN NULL;
END;
$$;


--
-- Name: propagate_meta_data_updates_to_media_resource(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.propagate_meta_data_updates_to_media_resource() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  md_id UUID;
BEGIN
  CASE
    WHEN TG_OP = 'DELETE' THEN
      md_id = OLD.id;
    ELSE
      md_id = NEW.id;
  END CASE;


  UPDATE media_entries SET meta_data_updated_at = now()
    FROM meta_data
    WHERE meta_data.media_entry_id = media_entries.id
    AND meta_data.id = md_id;

  UPDATE collections SET meta_data_updated_at = now()
    FROM meta_data
    WHERE meta_data.collection_id = collections.id
    AND meta_data.id = md_id;

  UPDATE filter_sets SET meta_data_updated_at = now()
    FROM meta_data
    WHERE meta_data.media_entry_id = filter_sets.id
    AND meta_data.id = md_id;


  RETURN NULL;
END;
$$;


--
-- Name: propagate_people_updates_to_meta_data_people(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.propagate_people_updates_to_meta_data_people() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE meta_data_people
    SET meta_data_updated_at = now()
    WHERE person_id = NEW.id;
  RETURN NULL;
END;
$$;


--
-- Name: static_pages_check_content_for_default_locale(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.static_pages_check_content_for_default_locale() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
  default_locale_from_app_settings varchar(5);
BEGIN
  default_locale_from_app_settings := (SELECT default_locale FROM app_settings LIMIT 1);
  IF
    NEW.contents->(default_locale_from_app_settings) ~ '^ *$'
    OR NEW.contents->(default_locale_from_app_settings) IS NULL
  THEN RAISE EXCEPTION 'Content for % locale cannot be blank!', upper(default_locale_from_app_settings);
  END IF;
  RETURN NEW;
END;
$_$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   NEW.updated_at = now();
   RETURN NEW;
END;
$$;


--
-- Name: users_update_searchable_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.users_update_searchable_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   NEW.searchable = COALESCE(NEW.login::text, '') || ' ' || COALESCE(NEW.email::text, '') ;
   RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: admins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admins (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: api_clients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.api_clients (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    login character varying NOT NULL,
    description text,
    password_digest character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT name_format CHECK (((login)::text ~ '^[a-z][a-z0-9\-\_]+$'::text))
);


--
-- Name: api_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.api_tokens (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    token_hash character varying(45) NOT NULL,
    token_part character varying(5) NOT NULL,
    revoked boolean DEFAULT false NOT NULL,
    scope_read boolean DEFAULT true NOT NULL,
    scope_write boolean DEFAULT false NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    expires_at timestamp with time zone DEFAULT (now() + '1 year'::interval) NOT NULL
);


--
-- Name: app_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_settings (
    id integer DEFAULT 0 NOT NULL,
    featured_set_id uuid,
    splashscreen_slideshow_set_id uuid,
    teaser_set_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    brand_logo_url character varying,
    sitemap jsonb DEFAULT '{"de": [{"Medienarchiv ZHdK": "http://medienarchiv.zhdk.ch"}, {"Madek-Projekt auf GitHub": "https://github.com/Madek"}], "en": [{"Media Archiv ZHdK": "http://medienarchiv.zhdk.ch"}, {"Madek Project on Github": "https://github.com/Madek"}]}'::jsonb NOT NULL,
    contexts_for_entry_extra text[] DEFAULT '{}'::text[] NOT NULL,
    contexts_for_list_details text[] DEFAULT '{}'::text[] NOT NULL,
    contexts_for_entry_validation text[] DEFAULT '{}'::text[] NOT NULL,
    contexts_for_dynamic_filters text[] DEFAULT '{}'::text[] NOT NULL,
    context_for_entry_summary text,
    context_for_collection_summary text,
    catalog_context_keys text[] DEFAULT '{}'::text[] NOT NULL,
    contexts_for_entry_edit text[] DEFAULT '{}'::text[] NOT NULL,
    contexts_for_collection_edit text[] DEFAULT '{}'::text[] NOT NULL,
    contexts_for_collection_extra text[] DEFAULT '{}'::text[] NOT NULL,
    media_entry_default_license_id uuid,
    media_entry_default_license_meta_key text,
    media_entry_default_license_usage_text text,
    media_entry_default_license_usage_meta_key text,
    ignored_keyword_keys_for_browsing text,
    default_locale character varying DEFAULT 'de'::character varying,
    available_locales character varying[] DEFAULT '{}'::character varying[],
    site_titles public.hstore DEFAULT ''::public.hstore NOT NULL,
    brand_texts public.hstore DEFAULT ''::public.hstore NOT NULL,
    welcome_titles public.hstore DEFAULT ''::public.hstore NOT NULL,
    welcome_texts public.hstore DEFAULT ''::public.hstore NOT NULL,
    featured_set_titles public.hstore DEFAULT ''::public.hstore NOT NULL,
    featured_set_subtitles public.hstore DEFAULT ''::public.hstore NOT NULL,
    catalog_titles public.hstore DEFAULT ''::public.hstore NOT NULL,
    catalog_subtitles public.hstore DEFAULT ''::public.hstore NOT NULL,
    about_pages public.hstore DEFAULT ''::public.hstore NOT NULL,
    support_urls public.hstore DEFAULT ''::public.hstore NOT NULL,
    provenance_notices public.hstore DEFAULT ''::public.hstore NOT NULL,
    time_zone character varying DEFAULT 'Europe/Zurich'::character varying NOT NULL,
    copyright_notice_templates text[] DEFAULT '{}'::text[],
    copyright_notice_default_text character varying,
    CONSTRAINT oneandonly CHECK ((id = 0))
);


--
-- Name: app_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.app_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: app_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.app_settings_id_seq OWNED BY public.app_settings.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: collection_api_client_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection_api_client_permissions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    get_metadata_and_previews boolean DEFAULT false NOT NULL,
    edit_metadata_and_relations boolean DEFAULT false NOT NULL,
    collection_id uuid NOT NULL,
    api_client_id uuid NOT NULL,
    updator_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: collection_collection_arcs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection_collection_arcs (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    child_id uuid NOT NULL,
    parent_id uuid NOT NULL,
    highlight boolean DEFAULT false,
    "order" double precision,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    "position" integer
);


--
-- Name: collection_filter_set_arcs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection_filter_set_arcs (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    filter_set_id uuid NOT NULL,
    collection_id uuid NOT NULL,
    highlight boolean DEFAULT false,
    "position" integer
);


--
-- Name: collection_group_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection_group_permissions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    get_metadata_and_previews boolean DEFAULT false NOT NULL,
    edit_metadata_and_relations boolean DEFAULT false NOT NULL,
    collection_id uuid NOT NULL,
    group_id uuid NOT NULL,
    updator_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: collection_media_entry_arcs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection_media_entry_arcs (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    media_entry_id uuid NOT NULL,
    collection_id uuid NOT NULL,
    highlight boolean DEFAULT false,
    cover boolean,
    "order" double precision,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    "position" integer
);


--
-- Name: collection_user_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection_user_permissions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    get_metadata_and_previews boolean DEFAULT false NOT NULL,
    edit_metadata_and_relations boolean DEFAULT false NOT NULL,
    edit_permissions boolean DEFAULT false NOT NULL,
    collection_id uuid NOT NULL,
    user_id uuid,
    updator_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    delegation_id uuid,
    CONSTRAINT user_id_or_delegation_id_not_null_at_the_same_time CHECK ((((user_id IS NOT NULL) AND (delegation_id IS NULL)) OR ((user_id IS NULL) AND (delegation_id IS NOT NULL))))
);


--
-- Name: collections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collections (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    get_metadata_and_previews boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    layout public.collection_layout DEFAULT 'grid'::public.collection_layout NOT NULL,
    responsible_user_id uuid,
    creator_id uuid NOT NULL,
    edit_session_updated_at timestamp with time zone DEFAULT now() NOT NULL,
    meta_data_updated_at timestamp with time zone DEFAULT now() NOT NULL,
    clipboard_user_id character varying,
    workflow_id uuid,
    is_master boolean DEFAULT false NOT NULL,
    sorting public.collection_sorting DEFAULT 'created_at DESC'::public.collection_sorting NOT NULL,
    responsible_delegation_id uuid,
    default_context_id character varying,
    CONSTRAINT one_responsible_column_is_not_null_at_the_same_time CHECK ((((responsible_user_id IS NULL) AND (responsible_delegation_id IS NOT NULL)) OR ((responsible_user_id IS NOT NULL) AND (responsible_delegation_id IS NULL))))
);


--
-- Name: confidential_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.confidential_links (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    resource_type character varying,
    resource_id uuid,
    token character varying(45) NOT NULL,
    revoked boolean DEFAULT false NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    expires_at timestamp with time zone
);


--
-- Name: context_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.context_keys (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    context_id character varying NOT NULL,
    meta_key_id character varying NOT NULL,
    is_required boolean DEFAULT false NOT NULL,
    length_max integer,
    length_min integer,
    "position" integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    admin_comment text,
    labels public.hstore DEFAULT ''::public.hstore NOT NULL,
    descriptions public.hstore DEFAULT ''::public.hstore NOT NULL,
    hints public.hstore DEFAULT ''::public.hstore NOT NULL,
    documentation_urls public.hstore DEFAULT ''::public.hstore NOT NULL,
    CONSTRAINT descriptions_non_blank CHECK (('^ *$'::text !~ ALL (public.avals(descriptions)))),
    CONSTRAINT hints_non_blank CHECK (('^ *$'::text !~ ALL (public.avals(hints)))),
    CONSTRAINT labels_non_blank CHECK (('^ *$'::text !~ ALL (public.avals(labels))))
);


--
-- Name: contexts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contexts (
    id character varying NOT NULL,
    admin_comment text,
    labels public.hstore DEFAULT ''::public.hstore NOT NULL,
    descriptions public.hstore DEFAULT ''::public.hstore NOT NULL,
    CONSTRAINT context_id_chars CHECK (((id)::text ~* '^[a-z0-9\-\_]+$'::text))
);


--
-- Name: custom_urls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_urls (
    id character varying NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    creator_id uuid NOT NULL,
    updator_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    media_entry_id uuid,
    collection_id uuid,
    filter_set_id uuid,
    CONSTRAINT custom_url_is_related CHECK ((((media_entry_id IS NULL) AND (collection_id IS NULL) AND (filter_set_id IS NOT NULL)) OR ((media_entry_id IS NULL) AND (collection_id IS NOT NULL) AND (filter_set_id IS NULL)) OR ((media_entry_id IS NOT NULL) AND (collection_id IS NULL) AND (filter_set_id IS NULL)))),
    CONSTRAINT custom_urls_id_format CHECK (((id)::text ~ '^[a-z][a-z0-9\-\_]+$'::text)),
    CONSTRAINT custom_urls_id_is_not_uuid CHECK ((NOT ((id)::text ~* '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'::text)))
);


--
-- Name: delegations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delegations (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    description text,
    admin_comment text
);


--
-- Name: delegations_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delegations_groups (
    delegation_id uuid NOT NULL,
    group_id uuid NOT NULL
);


--
-- Name: delegations_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delegations_users (
    delegation_id uuid NOT NULL,
    user_id uuid NOT NULL
);


--
-- Name: delegations_workflows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delegations_workflows (
    delegation_id uuid NOT NULL,
    workflow_id uuid NOT NULL
);


--
-- Name: edit_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.edit_sessions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    media_entry_id uuid,
    collection_id uuid,
    filter_set_id uuid,
    CONSTRAINT edit_sessions_is_related CHECK ((((media_entry_id IS NULL) AND (collection_id IS NULL) AND (filter_set_id IS NOT NULL)) OR ((media_entry_id IS NULL) AND (collection_id IS NOT NULL) AND (filter_set_id IS NULL)) OR ((media_entry_id IS NOT NULL) AND (collection_id IS NULL) AND (filter_set_id IS NULL))))
);


--
-- Name: favorite_collections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorite_collections (
    user_id uuid NOT NULL,
    collection_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: favorite_filter_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorite_filter_sets (
    user_id uuid NOT NULL,
    filter_set_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: favorite_media_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorite_media_entries (
    user_id uuid NOT NULL,
    media_entry_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: filter_set_api_client_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.filter_set_api_client_permissions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    get_metadata_and_previews boolean DEFAULT false NOT NULL,
    edit_metadata_and_filter boolean DEFAULT false NOT NULL,
    filter_set_id uuid NOT NULL,
    api_client_id uuid NOT NULL,
    updator_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: filter_set_group_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.filter_set_group_permissions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    get_metadata_and_previews boolean DEFAULT false NOT NULL,
    filter_set_id uuid NOT NULL,
    group_id uuid NOT NULL,
    updator_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: filter_set_user_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.filter_set_user_permissions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    get_metadata_and_previews boolean DEFAULT false NOT NULL,
    edit_metadata_and_filter boolean DEFAULT false NOT NULL,
    edit_permissions boolean DEFAULT false NOT NULL,
    filter_set_id uuid NOT NULL,
    user_id uuid,
    updator_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    delegation_id uuid,
    CONSTRAINT user_id_or_delegation_id_not_null_at_the_same_time CHECK ((((user_id IS NOT NULL) AND (delegation_id IS NULL)) OR ((user_id IS NULL) AND (delegation_id IS NOT NULL))))
);


--
-- Name: filter_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.filter_sets (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    get_metadata_and_previews boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    definition jsonb DEFAULT '{}'::jsonb NOT NULL,
    responsible_user_id uuid,
    creator_id uuid NOT NULL,
    edit_session_updated_at timestamp with time zone DEFAULT now() NOT NULL,
    meta_data_updated_at timestamp with time zone DEFAULT now() NOT NULL,
    responsible_delegation_id uuid,
    CONSTRAINT one_responsible_column_is_not_null_at_the_same_time CHECK ((((responsible_user_id IS NULL) AND (responsible_delegation_id IS NOT NULL)) OR ((responsible_user_id IS NOT NULL) AND (responsible_delegation_id IS NULL))))
);


--
-- Name: full_texts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.full_texts (
    media_resource_id uuid NOT NULL,
    text text
);


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text NOT NULL,
    institutional_id character varying,
    institutional_name character varying,
    type character varying DEFAULT 'Group'::character varying NOT NULL,
    person_id uuid,
    searchable text DEFAULT ''::text NOT NULL,
    CONSTRAINT check_valid_type CHECK (((type)::text = ANY ((ARRAY['AuthenticationGroup'::character varying, 'InstitutionalGroup'::character varying, 'Group'::character varying])::text[])))
);


--
-- Name: groups_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups_users (
    group_id uuid NOT NULL,
    user_id uuid NOT NULL
);


--
-- Name: io_interfaces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.io_interfaces (
    id character varying NOT NULL,
    description character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: io_mappings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.io_mappings (
    io_interface_id character varying NOT NULL,
    meta_key_id character varying NOT NULL,
    key_map character varying,
    key_map_type character varying,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    id uuid DEFAULT public.gen_random_uuid() NOT NULL
);


--
-- Name: keywords; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.keywords (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    term character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    creator_id uuid,
    meta_key_id character varying NOT NULL,
    "position" integer,
    rdf_class character varying DEFAULT 'Keyword'::character varying NOT NULL,
    description text,
    external_uris character varying[] DEFAULT '{}'::character varying[]
);


--
-- Name: media_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.media_entries (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    get_metadata_and_previews boolean DEFAULT false NOT NULL,
    get_full_size boolean DEFAULT false NOT NULL,
    responsible_user_id uuid,
    creator_id uuid NOT NULL,
    is_published boolean DEFAULT false,
    edit_session_updated_at timestamp with time zone DEFAULT now() NOT NULL,
    meta_data_updated_at timestamp with time zone DEFAULT now() NOT NULL,
    responsible_delegation_id uuid,
    CONSTRAINT one_responsible_column_is_not_null_at_the_same_time CHECK ((((responsible_user_id IS NULL) AND (responsible_delegation_id IS NOT NULL)) OR ((responsible_user_id IS NOT NULL) AND (responsible_delegation_id IS NULL))))
);


--
-- Name: media_entry_api_client_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.media_entry_api_client_permissions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    get_metadata_and_previews boolean DEFAULT false NOT NULL,
    get_full_size boolean DEFAULT false NOT NULL,
    media_entry_id uuid NOT NULL,
    api_client_id uuid NOT NULL,
    updator_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: media_entry_group_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.media_entry_group_permissions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    get_metadata_and_previews boolean DEFAULT false NOT NULL,
    get_full_size boolean DEFAULT false NOT NULL,
    edit_metadata boolean DEFAULT false NOT NULL,
    media_entry_id uuid NOT NULL,
    group_id uuid NOT NULL,
    updator_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: media_entry_user_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.media_entry_user_permissions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    get_metadata_and_previews boolean DEFAULT false NOT NULL,
    get_full_size boolean DEFAULT false NOT NULL,
    edit_metadata boolean DEFAULT false NOT NULL,
    edit_permissions boolean DEFAULT false NOT NULL,
    media_entry_id uuid NOT NULL,
    user_id uuid,
    updator_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    delegation_id uuid,
    CONSTRAINT user_id_or_delegation_id_not_null_at_the_same_time CHECK ((((user_id IS NOT NULL) AND (delegation_id IS NULL)) OR ((user_id IS NULL) AND (delegation_id IS NOT NULL))))
);


--
-- Name: media_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.media_files (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    height integer,
    size bigint,
    width integer,
    access_hash text,
    meta_data text,
    content_type character varying NOT NULL,
    filename character varying,
    guid character varying,
    extension character varying,
    media_type character varying,
    media_entry_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    uploader_id uuid NOT NULL,
    conversion_profiles character varying[] DEFAULT '{}'::character varying[]
);


--
-- Name: meta_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.meta_data (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    meta_key_id character varying NOT NULL,
    type character varying,
    string text,
    media_entry_id uuid,
    collection_id uuid,
    filter_set_id uuid,
    created_by_id uuid,
    meta_data_updated_at timestamp with time zone DEFAULT now() NOT NULL,
    json jsonb,
    other_media_entry_id uuid,
    CONSTRAINT check_valid_type CHECK (((type)::text = ANY ((ARRAY['MetaDatum::Groups'::character varying, 'MetaDatum::Keywords'::character varying, 'MetaDatum::Licenses'::character varying, 'MetaDatum::People'::character varying, 'MetaDatum::Roles'::character varying, 'MetaDatum::Text'::character varying, 'MetaDatum::TextDate'::character varying, 'MetaDatum::Users'::character varying, 'MetaDatum::Vocables'::character varying, 'MetaDatum::JSON'::character varying, 'MetaDatum::MediaEntry'::character varying])::text[]))),
    CONSTRAINT meta_data_is_related CHECK ((((media_entry_id IS NULL) AND (collection_id IS NULL) AND (filter_set_id IS NOT NULL)) OR ((media_entry_id IS NULL) AND (collection_id IS NOT NULL) AND (filter_set_id IS NULL)) OR ((media_entry_id IS NOT NULL) AND (collection_id IS NULL) AND (filter_set_id IS NULL))))
);


--
-- Name: meta_data_keywords; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.meta_data_keywords (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_by_id uuid,
    meta_datum_id uuid NOT NULL,
    keyword_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    meta_data_updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: meta_data_meta_terms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.meta_data_meta_terms (
    meta_datum_id uuid NOT NULL,
    meta_term_id uuid NOT NULL
);


--
-- Name: meta_data_people; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.meta_data_people (
    meta_datum_id uuid NOT NULL,
    person_id uuid NOT NULL,
    created_by_id uuid,
    meta_data_updated_at timestamp with time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL
);


--
-- Name: meta_data_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.meta_data_roles (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    meta_datum_id uuid,
    person_id uuid NOT NULL,
    role_id uuid,
    created_by_id uuid,
    "position" integer DEFAULT 0 NOT NULL
);


--
-- Name: meta_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.meta_keys (
    id character varying NOT NULL,
    is_extensible_list boolean DEFAULT false NOT NULL,
    meta_datum_object_type text DEFAULT 'MetaDatum::Text'::text NOT NULL,
    keywords_alphabetical_order boolean DEFAULT true NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    is_enabled_for_media_entries boolean DEFAULT false NOT NULL,
    is_enabled_for_collections boolean DEFAULT false NOT NULL,
    is_enabled_for_filter_sets boolean DEFAULT false NOT NULL,
    vocabulary_id character varying NOT NULL,
    admin_comment text,
    allowed_people_subtypes text[],
    text_type text DEFAULT 'line'::text NOT NULL,
    allowed_rdf_class character varying,
    labels public.hstore DEFAULT ''::public.hstore NOT NULL,
    descriptions public.hstore DEFAULT ''::public.hstore NOT NULL,
    hints public.hstore DEFAULT ''::public.hstore NOT NULL,
    documentation_urls public.hstore DEFAULT ''::public.hstore NOT NULL,
    CONSTRAINT check_allowed_people_subtypes_not_empty_for_meta_datum_people CHECK ((((allowed_people_subtypes IS NOT NULL) AND (COALESCE(array_length(allowed_people_subtypes, 1), 0) > 0)) OR (meta_datum_object_type <> 'MetaDatum::People'::text))),
    CONSTRAINT check_is_extensible_list_is_boolean_for_meta_datum_keywords CHECK (((((is_extensible_list = true) OR (is_extensible_list = false)) AND (meta_datum_object_type = 'MetaDatum::Keywords'::text)) OR (meta_datum_object_type <> 'MetaDatum::Keywords'::text))),
    CONSTRAINT check_keywords_alphabetical_order_is_boolean_for_meta_datum_key CHECK (((((keywords_alphabetical_order = true) OR (keywords_alphabetical_order = false)) AND (meta_datum_object_type = 'MetaDatum::Keywords'::text)) OR (meta_datum_object_type <> 'MetaDatum::Keywords'::text))),
    CONSTRAINT check_valid_meta_datum_object_type CHECK ((meta_datum_object_type = ANY (ARRAY['MetaDatum::Groups'::text, 'MetaDatum::Keywords'::text, 'MetaDatum::Licenses'::text, 'MetaDatum::People'::text, 'MetaDatum::Roles'::text, 'MetaDatum::Text'::text, 'MetaDatum::TextDate'::text, 'MetaDatum::Users'::text, 'MetaDatum::Vocables'::text, 'MetaDatum::JSON'::text, 'MetaDatum::MediaEntry'::text]))),
    CONSTRAINT check_valid_text_type CHECK ((text_type = ANY (ARRAY['line'::text, 'block'::text]))),
    CONSTRAINT descriptions_non_blank CHECK (('^ *$'::text !~ ALL (public.avals(descriptions)))),
    CONSTRAINT hints_non_blank CHECK (('^ *$'::text !~ ALL (public.avals(hints)))),
    CONSTRAINT labels_non_blank CHECK (('^ *$'::text !~ ALL (public.avals(labels)))),
    CONSTRAINT meta_key_id_chars CHECK (((id)::text ~* '^[a-z0-9\-\_\:]+$'::text)),
    CONSTRAINT start_id_like_vocabulary_id CHECK (((id)::text ~~ ((vocabulary_id)::text || ':%'::text)))
);


--
-- Name: people; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.people (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    first_name character varying,
    last_name character varying,
    pseudonym character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    searchable text DEFAULT ''::text NOT NULL,
    institutional_id text,
    subtype text NOT NULL,
    description text,
    external_uris character varying[] DEFAULT '{}'::character varying[],
    CONSTRAINT check_presence_of_first_name_or_last_name_or_pseudonym CHECK (((first_name IS NOT NULL) OR (last_name IS NOT NULL) OR (pseudonym IS NOT NULL))),
    CONSTRAINT check_valid_people_subtype CHECK ((subtype = ANY (ARRAY['Person'::text, 'PeopleGroup'::text, 'PeopleInstitutionalGroup'::text]))),
    CONSTRAINT first_name_is_not_blank CHECK (((first_name)::text !~ '^\s*$'::text)),
    CONSTRAINT institutional_id_is_not_blank CHECK ((institutional_id !~ '^\s*$'::text)),
    CONSTRAINT last_name_is_not_blank CHECK (((last_name)::text !~ '^\s*$'::text)),
    CONSTRAINT pseudonym_is_not_blank CHECK (((pseudonym)::text !~ '^\s*$'::text))
);


--
-- Name: previews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.previews (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    media_file_id uuid NOT NULL,
    height integer,
    width integer,
    content_type character varying,
    filename character varying,
    thumbnail character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    media_type character varying NOT NULL,
    conversion_profile character varying
);


--
-- Name: previous_group_ids; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.previous_group_ids (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    previous_id uuid NOT NULL,
    group_id uuid NOT NULL
);


--
-- Name: previous_keyword_ids; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.previous_keyword_ids (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    previous_id uuid NOT NULL,
    keyword_id uuid NOT NULL
);


--
-- Name: previous_person_ids; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.previous_person_ids (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    previous_id uuid NOT NULL,
    person_id uuid NOT NULL
);


--
-- Name: rdf_classes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rdf_classes (
    id character varying NOT NULL,
    description text,
    admin_comment text,
    "position" integer DEFAULT 0 NOT NULL,
    CONSTRAINT rdf_class_id_chars CHECK (((id)::text ~* '^[A-Za-z0-9]+$'::text)),
    CONSTRAINT rdf_class_id_start_uppercase CHECK (((id)::text ~ '^[A-Z]'::text))
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    labels public.hstore DEFAULT ''::public.hstore NOT NULL,
    meta_key_id character varying NOT NULL,
    creator_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT labels_non_blank CHECK ((array_to_string(public.avals(labels), ''::text) !~ '^ *$'::text))
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: static_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.static_pages (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    contents public.hstore DEFAULT ''::public.hstore NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT name_non_blank CHECK (((name)::text !~ '^ *$'::text))
);


--
-- Name: usage_terms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usage_terms (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    title character varying,
    version character varying,
    intro text,
    body text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    email character varying,
    login text,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    password_digest character varying,
    person_id uuid NOT NULL,
    institutional_id text,
    autocomplete text DEFAULT ''::text NOT NULL,
    searchable text DEFAULT ''::text NOT NULL,
    accepted_usage_terms_id uuid,
    last_signed_in_at timestamp with time zone,
    settings jsonb DEFAULT '{}'::jsonb NOT NULL,
    is_deactivated boolean DEFAULT false,
    CONSTRAINT email_format CHECK ((((email)::text ~ '\S+@\S+'::text) OR (email IS NULL))),
    CONSTRAINT users_login_simple CHECK ((login ~* '^[a-z0-9\.\-\_]+$'::text))
);


--
-- Name: users_workflows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_workflows (
    user_id uuid NOT NULL,
    workflow_id uuid NOT NULL
);


--
-- Name: visualizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.visualizations (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    resource_identifier character varying NOT NULL,
    control_settings text,
    layout text
);


--
-- Name: vocabularies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabularies (
    id character varying NOT NULL,
    enabled_for_public_view boolean DEFAULT true NOT NULL,
    enabled_for_public_use boolean DEFAULT true NOT NULL,
    admin_comment text,
    "position" integer NOT NULL,
    labels public.hstore DEFAULT ''::public.hstore NOT NULL,
    descriptions public.hstore DEFAULT ''::public.hstore NOT NULL,
    CONSTRAINT positive_position CHECK (("position" >= 0)),
    CONSTRAINT vocabulary_id_chars CHECK (((id)::text ~* '^[a-z0-9\-\_]+$'::text))
);


--
-- Name: vocabulary_api_client_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_api_client_permissions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    api_client_id uuid NOT NULL,
    vocabulary_id character varying NOT NULL,
    use boolean DEFAULT false NOT NULL,
    view boolean DEFAULT true NOT NULL
);


--
-- Name: vocabulary_group_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_group_permissions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    group_id uuid NOT NULL,
    vocabulary_id character varying NOT NULL,
    use boolean DEFAULT false NOT NULL,
    view boolean DEFAULT true NOT NULL
);


--
-- Name: vocabulary_user_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_user_permissions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    vocabulary_id character varying NOT NULL,
    use boolean DEFAULT false NOT NULL,
    view boolean DEFAULT true NOT NULL
);


--
-- Name: vw_media_resources; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_media_resources AS
 SELECT media_entries.id,
    media_entries.get_metadata_and_previews,
    media_entries.responsible_user_id,
    media_entries.creator_id,
    media_entries.created_at,
    media_entries.updated_at,
    'MediaEntry'::text AS type
   FROM public.media_entries
UNION
 SELECT collections.id,
    collections.get_metadata_and_previews,
    collections.responsible_user_id,
    collections.creator_id,
    collections.created_at,
    collections.updated_at,
    'Collection'::text AS type
   FROM public.collections
UNION
 SELECT filter_sets.id,
    filter_sets.get_metadata_and_previews,
    filter_sets.responsible_user_id,
    filter_sets.creator_id,
    filter_sets.created_at,
    filter_sets.updated_at,
    'FilterSet'::text AS type
   FROM public.filter_sets;


--
-- Name: workflows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workflows (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    creator_id uuid NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    configuration jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: zencoder_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.zencoder_jobs (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    media_file_id uuid NOT NULL,
    zencoder_id integer,
    comment text,
    state character varying DEFAULT 'initialized'::character varying NOT NULL,
    error text,
    notification text,
    request text,
    response text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    progress double precision DEFAULT 0.0,
    conversion_profiles character varying[] DEFAULT '{}'::character varying[]
);


--
-- Name: admins admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: api_clients api_clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_clients
    ADD CONSTRAINT api_clients_pkey PRIMARY KEY (id);


--
-- Name: api_tokens api_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_tokens
    ADD CONSTRAINT api_tokens_pkey PRIMARY KEY (id);


--
-- Name: api_tokens api_tokens_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_tokens
    ADD CONSTRAINT api_tokens_token_hash_key UNIQUE (token_hash);


--
-- Name: app_settings app_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_settings
    ADD CONSTRAINT app_settings_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: collection_api_client_permissions collection_api_client_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_api_client_permissions
    ADD CONSTRAINT collection_api_client_permissions_pkey PRIMARY KEY (id);


--
-- Name: collection_collection_arcs collection_collection_arcs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_collection_arcs
    ADD CONSTRAINT collection_collection_arcs_pkey PRIMARY KEY (id);


--
-- Name: collection_filter_set_arcs collection_filter_set_arcs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_filter_set_arcs
    ADD CONSTRAINT collection_filter_set_arcs_pkey PRIMARY KEY (id);


--
-- Name: collection_group_permissions collection_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_group_permissions
    ADD CONSTRAINT collection_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: collection_media_entry_arcs collection_media_entry_arcs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_media_entry_arcs
    ADD CONSTRAINT collection_media_entry_arcs_pkey PRIMARY KEY (id);


--
-- Name: collection_user_permissions collection_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_user_permissions
    ADD CONSTRAINT collection_user_permissions_pkey PRIMARY KEY (id);


--
-- Name: collections collections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT collections_pkey PRIMARY KEY (id);


--
-- Name: confidential_links confidential_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.confidential_links
    ADD CONSTRAINT confidential_links_pkey PRIMARY KEY (id);


--
-- Name: contexts contexts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contexts
    ADD CONSTRAINT contexts_pkey PRIMARY KEY (id);


--
-- Name: custom_urls custom_urls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_urls
    ADD CONSTRAINT custom_urls_pkey PRIMARY KEY (id);


--
-- Name: delegations delegations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delegations
    ADD CONSTRAINT delegations_pkey PRIMARY KEY (id);


--
-- Name: edit_sessions edit_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.edit_sessions
    ADD CONSTRAINT edit_sessions_pkey PRIMARY KEY (id);


--
-- Name: filter_set_api_client_permissions filter_set_api_client_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filter_set_api_client_permissions
    ADD CONSTRAINT filter_set_api_client_permissions_pkey PRIMARY KEY (id);


--
-- Name: filter_set_group_permissions filter_set_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filter_set_group_permissions
    ADD CONSTRAINT filter_set_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: filter_set_user_permissions filter_set_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filter_set_user_permissions
    ADD CONSTRAINT filter_set_user_permissions_pkey PRIMARY KEY (id);


--
-- Name: filter_sets filter_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filter_sets
    ADD CONSTRAINT filter_sets_pkey PRIMARY KEY (id);


--
-- Name: full_texts full_texts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.full_texts
    ADD CONSTRAINT full_texts_pkey PRIMARY KEY (media_resource_id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: io_interfaces io_interfaces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.io_interfaces
    ADD CONSTRAINT io_interfaces_pkey PRIMARY KEY (id);


--
-- Name: io_mappings io_mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.io_mappings
    ADD CONSTRAINT io_mappings_pkey PRIMARY KEY (id);


--
-- Name: keywords keyword_terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.keywords
    ADD CONSTRAINT keyword_terms_pkey PRIMARY KEY (id);


--
-- Name: meta_data_keywords keywords_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meta_data_keywords
    ADD CONSTRAINT keywords_pkey PRIMARY KEY (id);


--
-- Name: media_entries media_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_entries
    ADD CONSTRAINT media_entries_pkey PRIMARY KEY (id);


--
-- Name: media_entry_api_client_permissions media_entry_api_client_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_entry_api_client_permissions
    ADD CONSTRAINT media_entry_api_client_permissions_pkey PRIMARY KEY (id);


--
-- Name: media_entry_group_permissions media_entry_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_entry_group_permissions
    ADD CONSTRAINT media_entry_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: media_entry_user_permissions media_entry_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_entry_user_permissions
    ADD CONSTRAINT media_entry_user_permissions_pkey PRIMARY KEY (id);


--
-- Name: media_files media_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_files
    ADD CONSTRAINT media_files_pkey PRIMARY KEY (id);


--
-- Name: meta_data_people meta_data_people_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meta_data_people
    ADD CONSTRAINT meta_data_people_pkey PRIMARY KEY (id);


--
-- Name: meta_data meta_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meta_data
    ADD CONSTRAINT meta_data_pkey PRIMARY KEY (id);


--
-- Name: meta_data_roles meta_data_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meta_data_roles
    ADD CONSTRAINT meta_data_roles_pkey PRIMARY KEY (id);


--
-- Name: context_keys meta_key_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.context_keys
    ADD CONSTRAINT meta_key_definitions_pkey PRIMARY KEY (id);


--
-- Name: meta_keys meta_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meta_keys
    ADD CONSTRAINT meta_keys_pkey PRIMARY KEY (id);


--
-- Name: people people_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: previews previews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.previews
    ADD CONSTRAINT previews_pkey PRIMARY KEY (id);


--
-- Name: previous_group_ids previous_group_ids_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.previous_group_ids
    ADD CONSTRAINT previous_group_ids_pkey PRIMARY KEY (id);


--
-- Name: previous_keyword_ids previous_keyword_ids_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.previous_keyword_ids
    ADD CONSTRAINT previous_keyword_ids_pkey PRIMARY KEY (id);


--
-- Name: previous_person_ids previous_person_ids_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.previous_person_ids
    ADD CONSTRAINT previous_person_ids_pkey PRIMARY KEY (id);


--
-- Name: rdf_classes rdf_classes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rdf_classes
    ADD CONSTRAINT rdf_classes_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: static_pages static_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.static_pages
    ADD CONSTRAINT static_pages_pkey PRIMARY KEY (id);


--
-- Name: usage_terms usage_terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usage_terms
    ADD CONSTRAINT usage_terms_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: visualizations visualizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visualizations
    ADD CONSTRAINT visualizations_pkey PRIMARY KEY (id);


--
-- Name: vocabularies vocabularies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabularies
    ADD CONSTRAINT vocabularies_pkey PRIMARY KEY (id);


--
-- Name: vocabulary_api_client_permissions vocabulary_api_client_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_api_client_permissions
    ADD CONSTRAINT vocabulary_api_client_permissions_pkey PRIMARY KEY (id);


--
-- Name: vocabulary_group_permissions vocabulary_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_group_permissions
    ADD CONSTRAINT vocabulary_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: vocabulary_user_permissions vocabulary_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_user_permissions
    ADD CONSTRAINT vocabulary_user_permissions_pkey PRIMARY KEY (id);


--
-- Name: workflows workflows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflows
    ADD CONSTRAINT workflows_pkey PRIMARY KEY (id);


--
-- Name: zencoder_jobs zencoder_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zencoder_jobs
    ADD CONSTRAINT zencoder_jobs_pkey PRIMARY KEY (id);


--
-- Name: collection_collection_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX collection_collection_idx ON public.collection_collection_arcs USING btree (parent_id, "order");


--
-- Name: collection_media_entry_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX collection_media_entry_idx ON public.collection_media_entry_arcs USING btree (collection_id, "order");


--
-- Name: full_texts_text_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX full_texts_text_idx ON public.full_texts USING gin (text public.gin_trgm_ops);


--
-- Name: full_texts_to_tsvector_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX full_texts_to_tsvector_idx ON public.full_texts USING gin (to_tsvector('english'::regconfig, text));


--
-- Name: groups_searchable_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX groups_searchable_idx ON public.groups USING gin (searchable public.gin_trgm_ops);


--
-- Name: groups_to_tsvector_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX groups_to_tsvector_idx ON public.groups USING gin (to_tsvector('english'::regconfig, searchable));


--
-- Name: idx_colgrpp_edit_mdata_and_relations; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_colgrpp_edit_mdata_and_relations ON public.collection_group_permissions USING btree (edit_metadata_and_relations);


--
-- Name: idx_colgrpp_get_mdata_and_previews; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_colgrpp_get_mdata_and_previews ON public.collection_group_permissions USING btree (get_metadata_and_previews);


--
-- Name: idx_colgrpp_on_collection_id_and_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_colgrpp_on_collection_id_and_group_id ON public.collection_group_permissions USING btree (collection_id, group_id);


--
-- Name: idx_colgrpp_on_filter_set_id_and_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_colgrpp_on_filter_set_id_and_group_id ON public.filter_set_group_permissions USING btree (filter_set_id, group_id);


--
-- Name: idx_collapiclp_edit_mdata_and_relations; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_collapiclp_edit_mdata_and_relations ON public.collection_api_client_permissions USING btree (edit_metadata_and_relations);


--
-- Name: idx_collapiclp_get_mdata_and_previews; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_collapiclp_get_mdata_and_previews ON public.collection_api_client_permissions USING btree (get_metadata_and_previews);


--
-- Name: idx_collapiclp_on_collection_id_and_api_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_collapiclp_on_collection_id_and_api_client_id ON public.collection_api_client_permissions USING btree (collection_id, api_client_id);


--
-- Name: idx_collection_user_permission; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_collection_user_permission ON public.collection_user_permissions USING btree (collection_id, user_id);


--
-- Name: idx_colluserperm_edit_metadata_and_relations; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_colluserperm_edit_metadata_and_relations ON public.collection_user_permissions USING btree (edit_metadata_and_relations);


--
-- Name: idx_colluserperm_edit_permissions; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_colluserperm_edit_permissions ON public.collection_user_permissions USING btree (edit_permissions);


--
-- Name: idx_colluserperm_get_metadata_and_previews; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_colluserperm_get_metadata_and_previews ON public.collection_user_permissions USING btree (get_metadata_and_previews);


--
-- Name: idx_fsetapiclp_edit_mdata_and_filter; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fsetapiclp_edit_mdata_and_filter ON public.filter_set_api_client_permissions USING btree (edit_metadata_and_filter);


--
-- Name: idx_fsetapiclp_get_mdata_and_previews; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fsetapiclp_get_mdata_and_previews ON public.filter_set_api_client_permissions USING btree (get_metadata_and_previews);


--
-- Name: idx_fsetapiclp_on_filter_set_id_and_api_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_fsetapiclp_on_filter_set_id_and_api_client_id ON public.filter_set_api_client_permissions USING btree (filter_set_id, api_client_id);


--
-- Name: idx_fsetusrp_on_filter_set_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_fsetusrp_on_filter_set_id_and_user_id ON public.filter_set_user_permissions USING btree (filter_set_id, user_id);


--
-- Name: idx_me_apicl_get_mdata_and_previews; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_me_apicl_get_mdata_and_previews ON public.media_entry_api_client_permissions USING btree (get_metadata_and_previews);


--
-- Name: idx_media_entry_user_permission; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_media_entry_user_permission ON public.media_entry_user_permissions USING btree (media_entry_id, user_id);


--
-- Name: idx_megrpp_get_full_size; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_megrpp_get_full_size ON public.media_entry_api_client_permissions USING btree (get_full_size);


--
-- Name: idx_megrpp_get_mdata_and_previews; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_megrpp_get_mdata_and_previews ON public.media_entry_group_permissions USING btree (get_metadata_and_previews);


--
-- Name: idx_megrpp_on_media_entry_id_and_api_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_megrpp_on_media_entry_id_and_api_client_id ON public.media_entry_api_client_permissions USING btree (media_entry_id, api_client_id);


--
-- Name: idx_megrpp_on_media_entry_id_and_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_megrpp_on_media_entry_id_and_group_id ON public.media_entry_group_permissions USING btree (media_entry_id, group_id);


--
-- Name: idx_vocabulary_api_client; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_vocabulary_api_client ON public.vocabulary_api_client_permissions USING btree (api_client_id, vocabulary_id);


--
-- Name: idx_vocabulary_group; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_vocabulary_group ON public.vocabulary_group_permissions USING btree (group_id, vocabulary_id);


--
-- Name: idx_vocabulary_user; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_vocabulary_user ON public.vocabulary_user_permissions USING btree (user_id, vocabulary_id);


--
-- Name: index_admins_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admins_on_user_id ON public.admins USING btree (user_id);


--
-- Name: index_api_clients_on_login; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_api_clients_on_login ON public.api_clients USING btree (login);


--
-- Name: index_app_settings_on_copyright_notice_templates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_app_settings_on_copyright_notice_templates ON public.app_settings USING gin (copyright_notice_templates);


--
-- Name: index_collection_api_client_permissions_on_api_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_api_client_permissions_on_api_client_id ON public.collection_api_client_permissions USING btree (api_client_id);


--
-- Name: index_collection_api_client_permissions_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_api_client_permissions_on_collection_id ON public.collection_api_client_permissions USING btree (collection_id);


--
-- Name: index_collection_api_client_permissions_on_updator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_api_client_permissions_on_updator_id ON public.collection_api_client_permissions USING btree (updator_id);


--
-- Name: index_collection_collection_arcs_on_child_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_collection_arcs_on_child_id ON public.collection_collection_arcs USING btree (child_id);


--
-- Name: index_collection_collection_arcs_on_child_id_and_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_collection_arcs_on_child_id_and_parent_id ON public.collection_collection_arcs USING btree (child_id, parent_id);


--
-- Name: index_collection_collection_arcs_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_collection_arcs_on_parent_id ON public.collection_collection_arcs USING btree (parent_id);


--
-- Name: index_collection_collection_arcs_on_parent_id_and_child_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_collection_collection_arcs_on_parent_id_and_child_id ON public.collection_collection_arcs USING btree (parent_id, child_id);


--
-- Name: index_collection_collection_arcs_on_parent_id_and_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_collection_arcs_on_parent_id_and_position ON public.collection_collection_arcs USING btree (parent_id, "position");


--
-- Name: index_collection_filter_set_arcs_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_filter_set_arcs_on_collection_id ON public.collection_filter_set_arcs USING btree (collection_id);


--
-- Name: index_collection_filter_set_arcs_on_collection_id_and_filter_se; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_collection_filter_set_arcs_on_collection_id_and_filter_se ON public.collection_filter_set_arcs USING btree (collection_id, filter_set_id);


--
-- Name: index_collection_filter_set_arcs_on_collection_id_and_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_filter_set_arcs_on_collection_id_and_position ON public.collection_filter_set_arcs USING btree (collection_id, "position");


--
-- Name: index_collection_filter_set_arcs_on_filter_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_filter_set_arcs_on_filter_set_id ON public.collection_filter_set_arcs USING btree (filter_set_id);


--
-- Name: index_collection_filter_set_arcs_on_filter_set_id_and_collectio; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_filter_set_arcs_on_filter_set_id_and_collectio ON public.collection_filter_set_arcs USING btree (filter_set_id, collection_id);


--
-- Name: index_collection_group_permissions_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_group_permissions_on_collection_id ON public.collection_group_permissions USING btree (collection_id);


--
-- Name: index_collection_group_permissions_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_group_permissions_on_group_id ON public.collection_group_permissions USING btree (group_id);


--
-- Name: index_collection_group_permissions_on_updator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_group_permissions_on_updator_id ON public.collection_group_permissions USING btree (updator_id);


--
-- Name: index_collection_media_entry_arcs_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_media_entry_arcs_on_collection_id ON public.collection_media_entry_arcs USING btree (collection_id);


--
-- Name: index_collection_media_entry_arcs_on_collection_id_and_media_en; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_collection_media_entry_arcs_on_collection_id_and_media_en ON public.collection_media_entry_arcs USING btree (collection_id, media_entry_id);


--
-- Name: index_collection_media_entry_arcs_on_collection_id_and_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_media_entry_arcs_on_collection_id_and_position ON public.collection_media_entry_arcs USING btree (collection_id, "position");


--
-- Name: index_collection_media_entry_arcs_on_media_entry_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_media_entry_arcs_on_media_entry_id ON public.collection_media_entry_arcs USING btree (media_entry_id);


--
-- Name: index_collection_media_entry_arcs_on_media_entry_id_and_collect; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_media_entry_arcs_on_media_entry_id_and_collect ON public.collection_media_entry_arcs USING btree (media_entry_id, collection_id);


--
-- Name: index_collection_user_permissions_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_user_permissions_on_collection_id ON public.collection_user_permissions USING btree (collection_id);


--
-- Name: index_collection_user_permissions_on_delegation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_user_permissions_on_delegation_id ON public.collection_user_permissions USING btree (delegation_id);


--
-- Name: index_collection_user_permissions_on_updator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_user_permissions_on_updator_id ON public.collection_user_permissions USING btree (updator_id);


--
-- Name: index_collection_user_permissions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_user_permissions_on_user_id ON public.collection_user_permissions USING btree (user_id);


--
-- Name: index_collections_on_clipboard_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_collections_on_clipboard_user_id ON public.collections USING btree (clipboard_user_id);


--
-- Name: index_collections_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_created_at ON public.collections USING btree (created_at);


--
-- Name: index_collections_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_creator_id ON public.collections USING btree (creator_id);


--
-- Name: index_collections_on_default_context_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_default_context_id ON public.collections USING btree (default_context_id);


--
-- Name: index_collections_on_edit_session_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_edit_session_updated_at ON public.collections USING btree (edit_session_updated_at);


--
-- Name: index_collections_on_meta_data_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_meta_data_updated_at ON public.collections USING btree (meta_data_updated_at);


--
-- Name: index_collections_on_responsible_delegation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_responsible_delegation_id ON public.collections USING btree (responsible_delegation_id);


--
-- Name: index_collections_on_responsible_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_responsible_user_id ON public.collections USING btree (responsible_user_id);


--
-- Name: index_collections_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_updated_at ON public.collections USING btree (updated_at);


--
-- Name: index_collections_on_workflow_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_workflow_id ON public.collections USING btree (workflow_id);


--
-- Name: index_confidential_links_on_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_confidential_links_on_resource_type_and_resource_id ON public.confidential_links USING btree (resource_type, resource_id);


--
-- Name: index_context_keys_on_context_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_context_keys_on_context_id ON public.context_keys USING btree (context_id);


--
-- Name: index_context_keys_on_meta_key_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_context_keys_on_meta_key_id ON public.context_keys USING btree (meta_key_id);


--
-- Name: index_custom_urls_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_urls_on_creator_id ON public.custom_urls USING btree (creator_id);


--
-- Name: index_custom_urls_on_updator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_urls_on_updator_id ON public.custom_urls USING btree (updator_id);


--
-- Name: index_delegations_groups_on_delegation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delegations_groups_on_delegation_id ON public.delegations_groups USING btree (delegation_id);


--
-- Name: index_delegations_groups_on_delegation_id_and_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_delegations_groups_on_delegation_id_and_group_id ON public.delegations_groups USING btree (delegation_id, group_id);


--
-- Name: index_delegations_groups_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delegations_groups_on_group_id ON public.delegations_groups USING btree (group_id);


--
-- Name: index_delegations_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_delegations_on_name ON public.delegations USING btree (name);


--
-- Name: index_delegations_users_on_delegation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delegations_users_on_delegation_id ON public.delegations_users USING btree (delegation_id);


--
-- Name: index_delegations_users_on_delegation_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_delegations_users_on_delegation_id_and_user_id ON public.delegations_users USING btree (delegation_id, user_id);


--
-- Name: index_delegations_users_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delegations_users_on_user_id ON public.delegations_users USING btree (user_id);


--
-- Name: index_delegations_workflows_on_delegation_id_and_workflow_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_delegations_workflows_on_delegation_id_and_workflow_id ON public.delegations_workflows USING btree (delegation_id, workflow_id);


--
-- Name: index_delegations_workflows_on_workflow_id_and_delegation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delegations_workflows_on_workflow_id_and_delegation_id ON public.delegations_workflows USING btree (workflow_id, delegation_id);


--
-- Name: index_edit_sessions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_edit_sessions_on_user_id ON public.edit_sessions USING btree (user_id);


--
-- Name: index_favorite_collections_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorite_collections_on_collection_id ON public.favorite_collections USING btree (collection_id);


--
-- Name: index_favorite_collections_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorite_collections_on_user_id ON public.favorite_collections USING btree (user_id);


--
-- Name: index_favorite_collections_on_user_id_and_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_favorite_collections_on_user_id_and_collection_id ON public.favorite_collections USING btree (user_id, collection_id);


--
-- Name: index_favorite_filter_sets_on_filter_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorite_filter_sets_on_filter_set_id ON public.favorite_filter_sets USING btree (filter_set_id);


--
-- Name: index_favorite_filter_sets_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorite_filter_sets_on_user_id ON public.favorite_filter_sets USING btree (user_id);


--
-- Name: index_favorite_filter_sets_on_user_id_and_filter_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_favorite_filter_sets_on_user_id_and_filter_set_id ON public.favorite_filter_sets USING btree (user_id, filter_set_id);


--
-- Name: index_favorite_media_entries_on_media_entry_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorite_media_entries_on_media_entry_id ON public.favorite_media_entries USING btree (media_entry_id);


--
-- Name: index_favorite_media_entries_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorite_media_entries_on_user_id ON public.favorite_media_entries USING btree (user_id);


--
-- Name: index_favorite_media_entries_on_user_id_and_media_entry_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_favorite_media_entries_on_user_id_and_media_entry_id ON public.favorite_media_entries USING btree (user_id, media_entry_id);


--
-- Name: index_filter_set_api_client_permissions_on_api_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_filter_set_api_client_permissions_on_api_client_id ON public.filter_set_api_client_permissions USING btree (api_client_id);


--
-- Name: index_filter_set_api_client_permissions_on_filter_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_filter_set_api_client_permissions_on_filter_set_id ON public.filter_set_api_client_permissions USING btree (filter_set_id);


--
-- Name: index_filter_set_api_client_permissions_on_updator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_filter_set_api_client_permissions_on_updator_id ON public.filter_set_api_client_permissions USING btree (updator_id);


--
-- Name: index_filter_set_group_permissions_on_filter_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_filter_set_group_permissions_on_filter_set_id ON public.filter_set_group_permissions USING btree (filter_set_id);


--
-- Name: index_filter_set_group_permissions_on_get_metadata_and_previews; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_filter_set_group_permissions_on_get_metadata_and_previews ON public.filter_set_group_permissions USING btree (get_metadata_and_previews);


--
-- Name: index_filter_set_group_permissions_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_filter_set_group_permissions_on_group_id ON public.filter_set_group_permissions USING btree (group_id);


--
-- Name: index_filter_set_group_permissions_on_updator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_filter_set_group_permissions_on_updator_id ON public.filter_set_group_permissions USING btree (updator_id);


--
-- Name: index_filter_set_user_permissions_on_delegation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_filter_set_user_permissions_on_delegation_id ON public.filter_set_user_permissions USING btree (delegation_id);


--
-- Name: index_filter_set_user_permissions_on_edit_metadata_and_filter; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_filter_set_user_permissions_on_edit_metadata_and_filter ON public.filter_set_user_permissions USING btree (edit_metadata_and_filter);


--
-- Name: index_filter_set_user_permissions_on_edit_permissions; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_filter_set_user_permissions_on_edit_permissions ON public.filter_set_user_permissions USING btree (edit_permissions);


--
-- Name: index_filter_set_user_permissions_on_filter_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_filter_set_user_permissions_on_filter_set_id ON public.filter_set_user_permissions USING btree (filter_set_id);


--
-- Name: index_filter_set_user_permissions_on_get_metadata_and_previews; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_filter_set_user_permissions_on_get_metadata_and_previews ON public.filter_set_user_permissions USING btree (get_metadata_and_previews);


--
-- Name: index_filter_set_user_permissions_on_updator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_filter_set_user_permissions_on_updator_id ON public.filter_set_user_permissions USING btree (updator_id);


--
-- Name: index_filter_set_user_permissions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_filter_set_user_permissions_on_user_id ON public.filter_set_user_permissions USING btree (user_id);


--
-- Name: index_filter_sets_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_filter_sets_on_created_at ON public.filter_sets USING btree (created_at);


--
-- Name: index_filter_sets_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_filter_sets_on_creator_id ON public.filter_sets USING btree (creator_id);


--
-- Name: index_filter_sets_on_edit_session_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_filter_sets_on_edit_session_updated_at ON public.filter_sets USING btree (edit_session_updated_at);


--
-- Name: index_filter_sets_on_meta_data_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_filter_sets_on_meta_data_updated_at ON public.filter_sets USING btree (meta_data_updated_at);


--
-- Name: index_filter_sets_on_responsible_delegation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_filter_sets_on_responsible_delegation_id ON public.filter_sets USING btree (responsible_delegation_id);


--
-- Name: index_filter_sets_on_responsible_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_filter_sets_on_responsible_user_id ON public.filter_sets USING btree (responsible_user_id);


--
-- Name: index_filter_sets_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_filter_sets_on_updated_at ON public.filter_sets USING btree (updated_at);


--
-- Name: index_groups_on_institutional_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_groups_on_institutional_id ON public.groups USING btree (institutional_id);


--
-- Name: index_groups_on_institutional_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_institutional_name ON public.groups USING btree (institutional_name);


--
-- Name: index_groups_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_name ON public.groups USING btree (name);


--
-- Name: index_groups_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_type ON public.groups USING btree (type);


--
-- Name: index_groups_users_on_group_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_users_on_group_id_and_user_id ON public.groups_users USING btree (group_id, user_id);


--
-- Name: index_groups_users_on_user_id_and_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_groups_users_on_user_id_and_group_id ON public.groups_users USING btree (user_id, group_id);


--
-- Name: index_keywords_on_meta_key_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_keywords_on_meta_key_id ON public.keywords USING btree (meta_key_id);


--
-- Name: index_keywords_on_meta_key_id_and_term; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_keywords_on_meta_key_id_and_term ON public.keywords USING btree (meta_key_id, term);


--
-- Name: index_keywords_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_keywords_on_position ON public.keywords USING btree ("position");


--
-- Name: index_md_people_on_md_id_and_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_md_people_on_md_id_and_person_id ON public.meta_data_people USING btree (meta_datum_id, person_id);


--
-- Name: index_md_users_on_md_id_and_keyword_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_md_users_on_md_id_and_keyword_id ON public.meta_data_keywords USING btree (meta_datum_id, keyword_id);


--
-- Name: index_media_entries_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_entries_on_created_at ON public.media_entries USING btree (created_at);


--
-- Name: index_media_entries_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_entries_on_creator_id ON public.media_entries USING btree (creator_id);


--
-- Name: index_media_entries_on_edit_session_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_entries_on_edit_session_updated_at ON public.media_entries USING btree (edit_session_updated_at);


--
-- Name: index_media_entries_on_is_published; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_entries_on_is_published ON public.media_entries USING btree (is_published);


--
-- Name: index_media_entries_on_meta_data_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_entries_on_meta_data_updated_at ON public.media_entries USING btree (meta_data_updated_at);


--
-- Name: index_media_entries_on_responsible_delegation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_entries_on_responsible_delegation_id ON public.media_entries USING btree (responsible_delegation_id);


--
-- Name: index_media_entries_on_responsible_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_entries_on_responsible_user_id ON public.media_entries USING btree (responsible_user_id);


--
-- Name: index_media_entries_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_entries_on_updated_at ON public.media_entries USING btree (updated_at);


--
-- Name: index_media_entry_api_client_permissions_on_api_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_entry_api_client_permissions_on_api_client_id ON public.media_entry_api_client_permissions USING btree (api_client_id);


--
-- Name: index_media_entry_api_client_permissions_on_get_full_size; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_entry_api_client_permissions_on_get_full_size ON public.media_entry_api_client_permissions USING btree (get_full_size);


--
-- Name: index_media_entry_api_client_permissions_on_media_entry_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_entry_api_client_permissions_on_media_entry_id ON public.media_entry_api_client_permissions USING btree (media_entry_id);


--
-- Name: index_media_entry_api_client_permissions_on_updator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_entry_api_client_permissions_on_updator_id ON public.media_entry_api_client_permissions USING btree (updator_id);


--
-- Name: index_media_entry_group_permissions_on_edit_metadata; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_entry_group_permissions_on_edit_metadata ON public.media_entry_group_permissions USING btree (edit_metadata);


--
-- Name: index_media_entry_group_permissions_on_get_full_size; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_entry_group_permissions_on_get_full_size ON public.media_entry_group_permissions USING btree (get_full_size);


--
-- Name: index_media_entry_group_permissions_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_entry_group_permissions_on_group_id ON public.media_entry_group_permissions USING btree (group_id);


--
-- Name: index_media_entry_group_permissions_on_media_entry_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_entry_group_permissions_on_media_entry_id ON public.media_entry_group_permissions USING btree (media_entry_id);


--
-- Name: index_media_entry_group_permissions_on_updator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_entry_group_permissions_on_updator_id ON public.media_entry_group_permissions USING btree (updator_id);


--
-- Name: index_media_entry_user_permissions_on_delegation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_entry_user_permissions_on_delegation_id ON public.media_entry_user_permissions USING btree (delegation_id);


--
-- Name: index_media_entry_user_permissions_on_edit_metadata; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_entry_user_permissions_on_edit_metadata ON public.media_entry_user_permissions USING btree (edit_metadata);


--
-- Name: index_media_entry_user_permissions_on_edit_permissions; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_entry_user_permissions_on_edit_permissions ON public.media_entry_user_permissions USING btree (edit_permissions);


--
-- Name: index_media_entry_user_permissions_on_get_full_size; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_entry_user_permissions_on_get_full_size ON public.media_entry_user_permissions USING btree (get_full_size);


--
-- Name: index_media_entry_user_permissions_on_get_metadata_and_previews; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_entry_user_permissions_on_get_metadata_and_previews ON public.media_entry_user_permissions USING btree (get_metadata_and_previews);


--
-- Name: index_media_entry_user_permissions_on_media_entry_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_entry_user_permissions_on_media_entry_id ON public.media_entry_user_permissions USING btree (media_entry_id);


--
-- Name: index_media_entry_user_permissions_on_updator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_entry_user_permissions_on_updator_id ON public.media_entry_user_permissions USING btree (updator_id);


--
-- Name: index_media_entry_user_permissions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_entry_user_permissions_on_user_id ON public.media_entry_user_permissions USING btree (user_id);


--
-- Name: index_media_files_on_extension; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_files_on_extension ON public.media_files USING btree (extension);


--
-- Name: index_media_files_on_filename; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_files_on_filename ON public.media_files USING btree (filename);


--
-- Name: index_media_files_on_media_entry_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_files_on_media_entry_id ON public.media_files USING btree (media_entry_id);


--
-- Name: index_media_files_on_media_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_files_on_media_type ON public.media_files USING btree (media_type);


--
-- Name: index_meta_data_keywords_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meta_data_keywords_on_created_at ON public.meta_data_keywords USING btree (created_at);


--
-- Name: index_meta_data_keywords_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meta_data_keywords_on_created_by_id ON public.meta_data_keywords USING btree (created_by_id);


--
-- Name: index_meta_data_keywords_on_keyword_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meta_data_keywords_on_keyword_id ON public.meta_data_keywords USING btree (keyword_id);


--
-- Name: index_meta_data_keywords_on_meta_datum_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meta_data_keywords_on_meta_datum_id ON public.meta_data_keywords USING btree (meta_datum_id);


--
-- Name: index_meta_data_meta_terms_on_meta_datum_id_and_meta_term_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_meta_data_meta_terms_on_meta_datum_id_and_meta_term_id ON public.meta_data_meta_terms USING btree (meta_datum_id, meta_term_id);


--
-- Name: index_meta_data_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meta_data_on_collection_id ON public.meta_data USING btree (collection_id);


--
-- Name: index_meta_data_on_collection_id_and_meta_key_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_meta_data_on_collection_id_and_meta_key_id ON public.meta_data USING btree (collection_id, meta_key_id);


--
-- Name: index_meta_data_on_filter_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meta_data_on_filter_set_id ON public.meta_data USING btree (filter_set_id);


--
-- Name: index_meta_data_on_filter_set_id_and_meta_key_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_meta_data_on_filter_set_id_and_meta_key_id ON public.meta_data USING btree (filter_set_id, meta_key_id);


--
-- Name: index_meta_data_on_media_entry_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meta_data_on_media_entry_id ON public.meta_data USING btree (media_entry_id);


--
-- Name: index_meta_data_on_media_entry_id_and_meta_key_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_meta_data_on_media_entry_id_and_meta_key_id ON public.meta_data USING btree (media_entry_id, meta_key_id);


--
-- Name: index_meta_data_on_meta_key_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meta_data_on_meta_key_id ON public.meta_data USING btree (meta_key_id);


--
-- Name: index_meta_data_on_other_media_entry_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meta_data_on_other_media_entry_id ON public.meta_data USING btree (other_media_entry_id);


--
-- Name: index_meta_data_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meta_data_on_type ON public.meta_data USING btree (type);


--
-- Name: index_meta_data_roles_on_meta_datum_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meta_data_roles_on_meta_datum_id ON public.meta_data_roles USING btree (meta_datum_id);


--
-- Name: index_meta_data_roles_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meta_data_roles_on_person_id ON public.meta_data_roles USING btree (person_id);


--
-- Name: index_meta_data_roles_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meta_data_roles_on_position ON public.meta_data_roles USING btree ("position");


--
-- Name: index_meta_data_roles_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meta_data_roles_on_role_id ON public.meta_data_roles USING btree (role_id);


--
-- Name: index_people_on_first_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_people_on_first_name ON public.people USING btree (first_name);


--
-- Name: index_people_on_institutional_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_people_on_institutional_id ON public.people USING btree (institutional_id);


--
-- Name: index_people_on_last_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_people_on_last_name ON public.people USING btree (last_name);


--
-- Name: index_previews_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_previews_on_created_at ON public.previews USING btree (created_at);


--
-- Name: index_previews_on_media_file_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_previews_on_media_file_id ON public.previews USING btree (media_file_id);


--
-- Name: index_previews_on_media_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_previews_on_media_type ON public.previews USING btree (media_type);


--
-- Name: index_previous_group_ids_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_previous_group_ids_on_group_id ON public.previous_group_ids USING btree (group_id);


--
-- Name: index_previous_group_ids_on_previous_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_previous_group_ids_on_previous_id ON public.previous_group_ids USING btree (previous_id);


--
-- Name: index_previous_keyword_ids_on_keyword_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_previous_keyword_ids_on_keyword_id ON public.previous_keyword_ids USING btree (keyword_id);


--
-- Name: index_previous_keyword_ids_on_previous_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_previous_keyword_ids_on_previous_id ON public.previous_keyword_ids USING btree (previous_id);


--
-- Name: index_previous_person_ids_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_previous_person_ids_on_person_id ON public.previous_person_ids USING btree (person_id);


--
-- Name: index_previous_person_ids_on_previous_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_previous_person_ids_on_previous_id ON public.previous_person_ids USING btree (previous_id);


--
-- Name: index_roles_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_on_creator_id ON public.roles USING btree (creator_id);


--
-- Name: index_roles_on_meta_key_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_on_meta_key_id ON public.roles USING btree (meta_key_id);


--
-- Name: index_roles_on_meta_key_id_and_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_roles_on_meta_key_id_and_labels ON public.roles USING btree (meta_key_id, labels);


--
-- Name: index_static_pages_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_static_pages_on_name ON public.static_pages USING btree (name);


--
-- Name: index_users_on_autocomplete; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_autocomplete ON public.users USING btree (autocomplete);


--
-- Name: index_users_on_institutional_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_institutional_id ON public.users USING btree (institutional_id);


--
-- Name: index_users_on_login; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_login ON public.users USING btree (login);


--
-- Name: index_users_workflows_on_user_id_and_workflow_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_workflows_on_user_id_and_workflow_id ON public.users_workflows USING btree (user_id, workflow_id);


--
-- Name: index_users_workflows_on_workflow_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_workflows_on_workflow_id_and_user_id ON public.users_workflows USING btree (workflow_id, user_id);


--
-- Name: index_vocabularies_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vocabularies_on_position ON public.vocabularies USING btree ("position");


--
-- Name: index_zencoder_jobs_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_zencoder_jobs_on_created_at ON public.zencoder_jobs USING btree (created_at);


--
-- Name: index_zencoder_jobs_on_media_file_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_zencoder_jobs_on_media_file_id ON public.zencoder_jobs USING btree (media_file_id);


--
-- Name: index_zencoder_jobs_on_request; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_zencoder_jobs_on_request ON public.zencoder_jobs USING btree (request);


--
-- Name: index_zencoder_jobs_on_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_zencoder_jobs_on_state ON public.zencoder_jobs USING btree (state);


--
-- Name: keyword_terms_term_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX keyword_terms_term_idx ON public.keywords USING gin (term public.gin_trgm_ops);


--
-- Name: keyword_terms_to_tsvector_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX keyword_terms_to_tsvector_idx ON public.keywords USING gin (to_tsvector('english'::regconfig, (term)::text));


--
-- Name: meta_data_string_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX meta_data_string_idx ON public.meta_data USING gin (string public.gin_trgm_ops);


--
-- Name: meta_data_to_tsvector_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX meta_data_to_tsvector_idx ON public.meta_data USING gin (to_tsvector('english'::regconfig, string));


--
-- Name: people_searchable_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX people_searchable_idx ON public.people USING gin (searchable public.gin_trgm_ops);


--
-- Name: people_to_tsvector_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX people_to_tsvector_idx ON public.people USING gin (to_tsvector('english'::regconfig, searchable));


--
-- Name: unique_email_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_email_idx ON public.users USING btree (lower((email)::text));


--
-- Name: unique_login_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_login_idx ON public.users USING btree (login);


--
-- Name: users_searchable_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_searchable_idx ON public.users USING gin (searchable public.gin_trgm_ops);


--
-- Name: users_to_tsvector_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_to_tsvector_idx ON public.users USING gin (to_tsvector('english'::regconfig, searchable));


--
-- Name: static_pages check_contents_of_static_pages; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER check_contents_of_static_pages BEFORE INSERT OR UPDATE ON public.static_pages FOR EACH ROW EXECUTE PROCEDURE public.static_pages_check_content_for_default_locale();


--
-- Name: edit_sessions propagate_edit_session_insert_to_collections; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER propagate_edit_session_insert_to_collections AFTER INSERT ON public.edit_sessions FOR EACH ROW EXECUTE PROCEDURE public.propagate_edit_session_insert_to_collections();


--
-- Name: edit_sessions propagate_edit_session_insert_to_filter_sets; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER propagate_edit_session_insert_to_filter_sets AFTER INSERT ON public.edit_sessions FOR EACH ROW EXECUTE PROCEDURE public.propagate_edit_session_insert_to_filter_sets();


--
-- Name: edit_sessions propagate_edit_session_insert_to_media_entries; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER propagate_edit_session_insert_to_media_entries AFTER INSERT ON public.edit_sessions FOR EACH ROW EXECUTE PROCEDURE public.propagate_edit_session_insert_to_media_entries();


--
-- Name: keywords propagate_keyword_updates_to_meta_data_keywords; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER propagate_keyword_updates_to_meta_data_keywords AFTER INSERT OR UPDATE ON public.keywords FOR EACH ROW EXECUTE PROCEDURE public.propagate_keyword_updates_to_meta_data_keywords();


--
-- Name: meta_data_keywords propagate_meta_data_keyword_updates_to_meta_data; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER propagate_meta_data_keyword_updates_to_meta_data AFTER INSERT OR DELETE OR UPDATE ON public.meta_data_keywords FOR EACH ROW EXECUTE PROCEDURE public.propagate_meta_data_keyword_updates_to_meta_data();


--
-- Name: meta_data_people propagate_meta_data_people_updates_to_meta_data; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER propagate_meta_data_people_updates_to_meta_data AFTER INSERT OR DELETE OR UPDATE ON public.meta_data_people FOR EACH ROW EXECUTE PROCEDURE public.propagate_meta_data_people_updates_to_meta_data();


--
-- Name: meta_data propagate_meta_data_updates_to_media_resource; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER propagate_meta_data_updates_to_media_resource AFTER INSERT OR DELETE OR UPDATE ON public.meta_data FOR EACH ROW EXECUTE PROCEDURE public.propagate_meta_data_updates_to_media_resource();


--
-- Name: people propagate_people_updates_to_meta_data_people; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER propagate_people_updates_to_meta_data_people AFTER INSERT OR UPDATE ON public.people FOR EACH ROW EXECUTE PROCEDURE public.propagate_people_updates_to_meta_data_people();


--
-- Name: collection_media_entry_arcs trigger_check_collection_cover_uniqueness; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_check_collection_cover_uniqueness AFTER INSERT OR UPDATE ON public.collection_media_entry_arcs DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE public.check_collection_cover_uniqueness();


--
-- Name: custom_urls trigger_check_collection_primary_uniqueness; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_check_collection_primary_uniqueness AFTER INSERT OR UPDATE ON public.custom_urls DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE public.check_collection_primary_uniqueness();


--
-- Name: custom_urls trigger_check_filter_set_primary_uniqueness; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_check_filter_set_primary_uniqueness AFTER INSERT OR UPDATE ON public.custom_urls DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE public.check_filter_set_primary_uniqueness();


--
-- Name: custom_urls trigger_check_media_entry_primary_uniqueness; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_check_media_entry_primary_uniqueness AFTER INSERT OR UPDATE ON public.custom_urls DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE public.check_media_entry_primary_uniqueness();


--
-- Name: meta_data trigger_check_meta_data_created_by; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_check_meta_data_created_by AFTER INSERT ON public.meta_data FOR EACH ROW EXECUTE PROCEDURE public.check_meta_data_created_by();


--
-- Name: meta_data_keywords trigger_check_meta_data_keywords_created_by; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_check_meta_data_keywords_created_by AFTER INSERT ON public.meta_data_keywords FOR EACH ROW EXECUTE PROCEDURE public.check_meta_data_keywords_created_by();


--
-- Name: meta_data_people trigger_check_meta_data_people_created_by; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_check_meta_data_people_created_by AFTER INSERT ON public.meta_data_people FOR EACH ROW EXECUTE PROCEDURE public.check_meta_data_people_created_by();


--
-- Name: collection_media_entry_arcs trigger_check_no_drafts_in_collections; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_check_no_drafts_in_collections AFTER INSERT OR UPDATE ON public.collection_media_entry_arcs DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE public.check_no_drafts_in_collections();


--
-- Name: api_clients trigger_check_users_apiclients_login_uniqueness_on_apiclients; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_check_users_apiclients_login_uniqueness_on_apiclients AFTER INSERT OR UPDATE ON public.api_clients DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE public.check_users_apiclients_login_uniqueness();


--
-- Name: users trigger_check_users_apiclients_login_uniqueness_on_users; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_check_users_apiclients_login_uniqueness_on_users AFTER INSERT OR UPDATE ON public.users DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE public.check_users_apiclients_login_uniqueness();


--
-- Name: collection_collection_arcs trigger_collection_may_not_be_its_own_parent; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_collection_may_not_be_its_own_parent AFTER INSERT OR UPDATE ON public.collection_collection_arcs DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE public.collection_may_not_be_its_own_parent();


--
-- Name: groups_users trigger_delete_empty_group_after_delete_join; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_delete_empty_group_after_delete_join AFTER DELETE ON public.groups_users DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE public.delete_empty_group_after_delete_join();


--
-- Name: meta_data trigger_delete_empty_meta_data_groups_after_insert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_delete_empty_meta_data_groups_after_insert AFTER INSERT ON public.meta_data DEFERRABLE INITIALLY DEFERRED FOR EACH ROW WHEN (((new.type)::text = 'MetaDatum::Groups'::text)) EXECUTE PROCEDURE public.delete_empty_meta_data_groups_after_insert();


--
-- Name: meta_data_keywords trigger_delete_empty_meta_data_keywords_after_delete_join; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_delete_empty_meta_data_keywords_after_delete_join AFTER DELETE ON public.meta_data_keywords DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE public.delete_empty_meta_data_keywords_after_delete_join();


--
-- Name: meta_data trigger_delete_empty_meta_data_keywords_after_insert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_delete_empty_meta_data_keywords_after_insert AFTER INSERT ON public.meta_data DEFERRABLE INITIALLY DEFERRED FOR EACH ROW WHEN (((new.type)::text = 'MetaDatum::Keywords'::text)) EXECUTE PROCEDURE public.delete_empty_meta_data_keywords_after_insert();


--
-- Name: meta_data trigger_delete_empty_meta_data_licenses_after_insert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_delete_empty_meta_data_licenses_after_insert AFTER INSERT ON public.meta_data DEFERRABLE INITIALLY DEFERRED FOR EACH ROW WHEN (((new.type)::text = 'MetaDatum::Licenses'::text)) EXECUTE PROCEDURE public.delete_empty_meta_data_licenses_after_insert();


--
-- Name: meta_data_people trigger_delete_empty_meta_data_people_after_delete_join; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_delete_empty_meta_data_people_after_delete_join AFTER DELETE ON public.meta_data_people DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE public.delete_empty_meta_data_people_after_delete_join();


--
-- Name: meta_data trigger_delete_empty_meta_data_people_after_insert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_delete_empty_meta_data_people_after_insert AFTER INSERT ON public.meta_data DEFERRABLE INITIALLY DEFERRED FOR EACH ROW WHEN (((new.type)::text = 'MetaDatum::People'::text)) EXECUTE PROCEDURE public.delete_empty_meta_data_people_after_insert();


--
-- Name: meta_data trigger_delete_meta_datum_text_string_null; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_delete_meta_datum_text_string_null AFTER INSERT OR UPDATE ON public.meta_data DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE public.delete_meta_datum_text_string_null();


--
-- Name: meta_keys trigger_madek_core_meta_key_immutability; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_madek_core_meta_key_immutability AFTER INSERT OR DELETE OR UPDATE ON public.meta_keys DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE public.check_madek_core_meta_key_immutability();


--
-- Name: meta_data trigger_meta_data_meta_key_type_consistency; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_meta_data_meta_key_type_consistency AFTER INSERT OR UPDATE ON public.meta_data DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE public.check_meta_data_meta_key_type_consistency();


--
-- Name: meta_data_keywords trigger_meta_key_id_for_keyword_consistency; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_meta_key_id_for_keyword_consistency AFTER INSERT OR UPDATE ON public.meta_data_keywords DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE public.check_meta_key_id_consistency_for_keywords();


--
-- Name: meta_keys trigger_meta_key_meta_data_type_consistency; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_meta_key_meta_data_type_consistency AFTER INSERT OR UPDATE ON public.meta_keys DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE public.check_meta_key_meta_data_type_consistency();


--
-- Name: groups update_searchable_column_of_groups; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_searchable_column_of_groups BEFORE INSERT OR UPDATE ON public.groups FOR EACH ROW EXECUTE PROCEDURE public.groups_update_searchable_column();


--
-- Name: people update_searchable_column_of_people; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_searchable_column_of_people BEFORE INSERT OR UPDATE ON public.people FOR EACH ROW EXECUTE PROCEDURE public.people_update_searchable_column();


--
-- Name: users update_searchable_column_of_users; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_searchable_column_of_users BEFORE INSERT OR UPDATE ON public.users FOR EACH ROW EXECUTE PROCEDURE public.users_update_searchable_column();


--
-- Name: admins update_updated_at_column_of_admins; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_admins BEFORE UPDATE ON public.admins FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: api_clients update_updated_at_column_of_api_clients; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_api_clients BEFORE UPDATE ON public.api_clients FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: api_tokens update_updated_at_column_of_api_tokens; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_api_tokens BEFORE UPDATE ON public.api_tokens FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: app_settings update_updated_at_column_of_app_settings; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_app_settings BEFORE UPDATE ON public.app_settings FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: ar_internal_metadata update_updated_at_column_of_ar_internal_metadata; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_ar_internal_metadata BEFORE UPDATE ON public.ar_internal_metadata FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: collection_api_client_permissions update_updated_at_column_of_collection_api_client_permissions; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_collection_api_client_permissions BEFORE UPDATE ON public.collection_api_client_permissions FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: collection_collection_arcs update_updated_at_column_of_collection_collection_arcs; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_collection_collection_arcs BEFORE UPDATE ON public.collection_collection_arcs FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: collection_group_permissions update_updated_at_column_of_collection_group_permissions; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_collection_group_permissions BEFORE UPDATE ON public.collection_group_permissions FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: collection_media_entry_arcs update_updated_at_column_of_collection_media_entry_arcs; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_collection_media_entry_arcs BEFORE UPDATE ON public.collection_media_entry_arcs FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: collection_user_permissions update_updated_at_column_of_collection_user_permissions; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_collection_user_permissions BEFORE UPDATE ON public.collection_user_permissions FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: collections update_updated_at_column_of_collections; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_collections BEFORE UPDATE ON public.collections FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: confidential_links update_updated_at_column_of_confidential_links; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_confidential_links BEFORE UPDATE ON public.confidential_links FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: context_keys update_updated_at_column_of_context_keys; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_context_keys BEFORE UPDATE ON public.context_keys FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: custom_urls update_updated_at_column_of_custom_urls; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_custom_urls BEFORE UPDATE ON public.custom_urls FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: favorite_collections update_updated_at_column_of_favorite_collections; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_favorite_collections BEFORE UPDATE ON public.favorite_collections FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: favorite_filter_sets update_updated_at_column_of_favorite_filter_sets; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_favorite_filter_sets BEFORE UPDATE ON public.favorite_filter_sets FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: favorite_media_entries update_updated_at_column_of_favorite_media_entries; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_favorite_media_entries BEFORE UPDATE ON public.favorite_media_entries FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: filter_set_api_client_permissions update_updated_at_column_of_filter_set_api_client_permissions; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_filter_set_api_client_permissions BEFORE UPDATE ON public.filter_set_api_client_permissions FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: filter_set_group_permissions update_updated_at_column_of_filter_set_group_permissions; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_filter_set_group_permissions BEFORE UPDATE ON public.filter_set_group_permissions FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: filter_set_user_permissions update_updated_at_column_of_filter_set_user_permissions; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_filter_set_user_permissions BEFORE UPDATE ON public.filter_set_user_permissions FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: filter_sets update_updated_at_column_of_filter_sets; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_filter_sets BEFORE UPDATE ON public.filter_sets FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: io_interfaces update_updated_at_column_of_io_interfaces; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_io_interfaces BEFORE UPDATE ON public.io_interfaces FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: io_mappings update_updated_at_column_of_io_mappings; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_io_mappings BEFORE UPDATE ON public.io_mappings FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: keywords update_updated_at_column_of_keywords; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_keywords BEFORE UPDATE ON public.keywords FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: media_entries update_updated_at_column_of_media_entries; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_media_entries BEFORE UPDATE ON public.media_entries FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: media_entry_api_client_permissions update_updated_at_column_of_media_entry_api_client_permissions; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_media_entry_api_client_permissions BEFORE UPDATE ON public.media_entry_api_client_permissions FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: media_entry_group_permissions update_updated_at_column_of_media_entry_group_permissions; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_media_entry_group_permissions BEFORE UPDATE ON public.media_entry_group_permissions FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: media_entry_user_permissions update_updated_at_column_of_media_entry_user_permissions; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_media_entry_user_permissions BEFORE UPDATE ON public.media_entry_user_permissions FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: media_files update_updated_at_column_of_media_files; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_media_files BEFORE UPDATE ON public.media_files FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: meta_data_keywords update_updated_at_column_of_meta_data_keywords; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_meta_data_keywords BEFORE UPDATE ON public.meta_data_keywords FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: people update_updated_at_column_of_people; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_people BEFORE UPDATE ON public.people FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: previews update_updated_at_column_of_previews; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_previews BEFORE UPDATE ON public.previews FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: usage_terms update_updated_at_column_of_usage_terms; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_usage_terms BEFORE UPDATE ON public.usage_terms FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: users update_updated_at_column_of_users; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_users BEFORE UPDATE ON public.users FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: workflows update_updated_at_column_of_workflows; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_workflows BEFORE UPDATE ON public.workflows FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: zencoder_jobs update_updated_at_column_of_zencoder_jobs; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_updated_at_column_of_zencoder_jobs BEFORE UPDATE ON public.zencoder_jobs FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE PROCEDURE public.update_updated_at_column();


--
-- Name: admins admins_users_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_users_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: collection_api_client_permissions collection-api-client-permissions_api-clients_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_api_client_permissions
    ADD CONSTRAINT "collection-api-client-permissions_api-clients_fkey" FOREIGN KEY (api_client_id) REFERENCES public.api_clients(id) ON DELETE CASCADE;


--
-- Name: collection_api_client_permissions collection-api-client-permissions_collections_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_api_client_permissions
    ADD CONSTRAINT "collection-api-client-permissions_collections_fkey" FOREIGN KEY (collection_id) REFERENCES public.collections(id) ON DELETE CASCADE;


--
-- Name: collection_api_client_permissions collection-api-client-permissions_updators_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_api_client_permissions
    ADD CONSTRAINT "collection-api-client-permissions_updators_fkey" FOREIGN KEY (updator_id) REFERENCES public.users(id);


--
-- Name: collection_collection_arcs collection-collection-arcs_children_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_collection_arcs
    ADD CONSTRAINT "collection-collection-arcs_children_fkey" FOREIGN KEY (child_id) REFERENCES public.collections(id) ON DELETE CASCADE;


--
-- Name: collection_collection_arcs collection-collection-arcs_parents_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_collection_arcs
    ADD CONSTRAINT "collection-collection-arcs_parents_fkey" FOREIGN KEY (parent_id) REFERENCES public.collections(id) ON DELETE CASCADE;


--
-- Name: collection_filter_set_arcs collection-filter-set-arcs_collections_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_filter_set_arcs
    ADD CONSTRAINT "collection-filter-set-arcs_collections_fkey" FOREIGN KEY (collection_id) REFERENCES public.collections(id) ON DELETE CASCADE;


--
-- Name: collection_filter_set_arcs collection-filter-set-arcs_filter-sets_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_filter_set_arcs
    ADD CONSTRAINT "collection-filter-set-arcs_filter-sets_fkey" FOREIGN KEY (filter_set_id) REFERENCES public.filter_sets(id) ON DELETE CASCADE;


--
-- Name: collection_group_permissions collection-group-permissions_collections_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_group_permissions
    ADD CONSTRAINT "collection-group-permissions_collections_fkey" FOREIGN KEY (collection_id) REFERENCES public.collections(id) ON DELETE CASCADE;


--
-- Name: collection_group_permissions collection-group-permissions_updators_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_group_permissions
    ADD CONSTRAINT "collection-group-permissions_updators_fkey" FOREIGN KEY (updator_id) REFERENCES public.users(id);


--
-- Name: collection_media_entry_arcs collection-media-entry-arcs_collections_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_media_entry_arcs
    ADD CONSTRAINT "collection-media-entry-arcs_collections_fkey" FOREIGN KEY (collection_id) REFERENCES public.collections(id) ON DELETE CASCADE;


--
-- Name: collection_media_entry_arcs collection-media-entry-arcs_media-entries_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_media_entry_arcs
    ADD CONSTRAINT "collection-media-entry-arcs_media-entries_fkey" FOREIGN KEY (media_entry_id) REFERENCES public.media_entries(id) ON DELETE CASCADE;


--
-- Name: collection_user_permissions collection-user-permissions-updators_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_user_permissions
    ADD CONSTRAINT "collection-user-permissions-updators_fkey" FOREIGN KEY (updator_id) REFERENCES public.users(id);


--
-- Name: collection_user_permissions collection-user-permissions_collections_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_user_permissions
    ADD CONSTRAINT "collection-user-permissions_collections_fkey" FOREIGN KEY (collection_id) REFERENCES public.collections(id) ON DELETE CASCADE;


--
-- Name: collection_user_permissions collection-user-permissions_users_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_user_permissions
    ADD CONSTRAINT "collection-user-permissions_users_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: collections collections_creators_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT collections_creators_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: collections collections_responsible-users_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT "collections_responsible-users_fkey" FOREIGN KEY (responsible_user_id) REFERENCES public.users(id);


--
-- Name: custom_urls custom-urls_collections_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_urls
    ADD CONSTRAINT "custom-urls_collections_fkey" FOREIGN KEY (collection_id) REFERENCES public.collections(id) ON DELETE CASCADE;


--
-- Name: custom_urls custom-urls_creators_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_urls
    ADD CONSTRAINT "custom-urls_creators_fkey" FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: custom_urls custom-urls_filter-sets_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_urls
    ADD CONSTRAINT "custom-urls_filter-sets_fkey" FOREIGN KEY (filter_set_id) REFERENCES public.filter_sets(id) ON DELETE CASCADE;


--
-- Name: custom_urls custom-urls_media-entries_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_urls
    ADD CONSTRAINT "custom-urls_media-entries_fkey" FOREIGN KEY (media_entry_id) REFERENCES public.media_entries(id) ON DELETE CASCADE;


--
-- Name: custom_urls custom-urls_updators_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_urls
    ADD CONSTRAINT "custom-urls_updators_fkey" FOREIGN KEY (updator_id) REFERENCES public.users(id);


--
-- Name: edit_sessions edit-sessions_collections_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.edit_sessions
    ADD CONSTRAINT "edit-sessions_collections_fkey" FOREIGN KEY (collection_id) REFERENCES public.collections(id) ON DELETE CASCADE;


--
-- Name: edit_sessions edit-sessions_filter-sets_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.edit_sessions
    ADD CONSTRAINT "edit-sessions_filter-sets_fkey" FOREIGN KEY (filter_set_id) REFERENCES public.filter_sets(id) ON DELETE CASCADE;


--
-- Name: edit_sessions edit-sessions_media-entries_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.edit_sessions
    ADD CONSTRAINT "edit-sessions_media-entries_fkey" FOREIGN KEY (media_entry_id) REFERENCES public.media_entries(id) ON DELETE CASCADE;


--
-- Name: edit_sessions edit-sessions_users_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.edit_sessions
    ADD CONSTRAINT "edit-sessions_users_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: favorite_collections favorite-collections_collections_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorite_collections
    ADD CONSTRAINT "favorite-collections_collections_fkey" FOREIGN KEY (collection_id) REFERENCES public.collections(id) ON DELETE CASCADE;


--
-- Name: favorite_collections favorite-collections_users_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorite_collections
    ADD CONSTRAINT "favorite-collections_users_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: favorite_filter_sets favorite-filter-sets_filter-sets_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorite_filter_sets
    ADD CONSTRAINT "favorite-filter-sets_filter-sets_fkey" FOREIGN KEY (filter_set_id) REFERENCES public.filter_sets(id) ON DELETE CASCADE;


--
-- Name: favorite_filter_sets favorite-filter-sets_users_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorite_filter_sets
    ADD CONSTRAINT "favorite-filter-sets_users_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: favorite_media_entries favorite-media-entries_media-entries_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorite_media_entries
    ADD CONSTRAINT "favorite-media-entries_media-entries_fkey" FOREIGN KEY (media_entry_id) REFERENCES public.media_entries(id) ON DELETE CASCADE;


--
-- Name: favorite_media_entries favorite-media-entries_users_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorite_media_entries
    ADD CONSTRAINT "favorite-media-entries_users_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: filter_set_api_client_permissions filter-set-api-client-permissions-updators_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filter_set_api_client_permissions
    ADD CONSTRAINT "filter-set-api-client-permissions-updators_fkey" FOREIGN KEY (updator_id) REFERENCES public.users(id);


--
-- Name: filter_set_api_client_permissions filter-set-api-client-permissions_api-clients_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filter_set_api_client_permissions
    ADD CONSTRAINT "filter-set-api-client-permissions_api-clients_fkey" FOREIGN KEY (api_client_id) REFERENCES public.api_clients(id) ON DELETE CASCADE;


--
-- Name: filter_set_api_client_permissions filter-set-api-client-permissions_filter-sets_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filter_set_api_client_permissions
    ADD CONSTRAINT "filter-set-api-client-permissions_filter-sets_fkey" FOREIGN KEY (filter_set_id) REFERENCES public.filter_sets(id) ON DELETE CASCADE;


--
-- Name: filter_set_group_permissions filter-set-group-permissions_filter-sets_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filter_set_group_permissions
    ADD CONSTRAINT "filter-set-group-permissions_filter-sets_fkey" FOREIGN KEY (filter_set_id) REFERENCES public.filter_sets(id) ON DELETE CASCADE;


--
-- Name: filter_set_group_permissions filter-set-group-permissions_updators_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filter_set_group_permissions
    ADD CONSTRAINT "filter-set-group-permissions_updators_fkey" FOREIGN KEY (updator_id) REFERENCES public.users(id);


--
-- Name: filter_set_user_permissions filter-set-user-permissions_filter-sets_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filter_set_user_permissions
    ADD CONSTRAINT "filter-set-user-permissions_filter-sets_fkey" FOREIGN KEY (filter_set_id) REFERENCES public.filter_sets(id) ON DELETE CASCADE;


--
-- Name: filter_set_user_permissions filter-set-user-permissions_updators_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filter_set_user_permissions
    ADD CONSTRAINT "filter-set-user-permissions_updators_fkey" FOREIGN KEY (updator_id) REFERENCES public.users(id);


--
-- Name: filter_set_user_permissions filter-set-user-permissions_users_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filter_set_user_permissions
    ADD CONSTRAINT "filter-set-user-permissions_users_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: filter_sets filter-sets_creators_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filter_sets
    ADD CONSTRAINT "filter-sets_creators_fkey" FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: filter_sets filter-sets_responsible-users_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filter_sets
    ADD CONSTRAINT "filter-sets_responsible-users_fkey" FOREIGN KEY (responsible_user_id) REFERENCES public.users(id);


--
-- Name: context_keys fk_rails_2957e036b5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.context_keys
    ADD CONSTRAINT fk_rails_2957e036b5 FOREIGN KEY (meta_key_id) REFERENCES public.meta_keys(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: collections fk_rails_312d185db8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT fk_rails_312d185db8 FOREIGN KEY (responsible_delegation_id) REFERENCES public.delegations(id);


--
-- Name: api_clients fk_rails_45043d2037; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_clients
    ADD CONSTRAINT fk_rails_45043d2037 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: groups_users fk_rails_4e63edbd27; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups_users
    ADD CONSTRAINT fk_rails_4e63edbd27 FOREIGN KEY (group_id) REFERENCES public.groups(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: vocabulary_group_permissions fk_rails_8550647b84; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_group_permissions
    ADD CONSTRAINT fk_rails_8550647b84 FOREIGN KEY (group_id) REFERENCES public.groups(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: confidential_links fk_rails_8c2cb96882; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.confidential_links
    ADD CONSTRAINT fk_rails_8c2cb96882 FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: collection_user_permissions fk_rails_8f830fb7e7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_user_permissions
    ADD CONSTRAINT fk_rails_8f830fb7e7 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: collections fk_rails_9085ae39f1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT fk_rails_9085ae39f1 FOREIGN KEY (workflow_id) REFERENCES public.workflows(id);


--
-- Name: roles fk_rails_973fbfab62; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT fk_rails_973fbfab62 FOREIGN KEY (meta_key_id) REFERENCES public.meta_keys(id);


--
-- Name: filter_set_group_permissions fk_rails_9cf683b9d3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filter_set_group_permissions
    ADD CONSTRAINT fk_rails_9cf683b9d3 FOREIGN KEY (group_id) REFERENCES public.groups(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: delegations_groups fk_rails_a507ac19bd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delegations_groups
    ADD CONSTRAINT fk_rails_a507ac19bd FOREIGN KEY (delegation_id) REFERENCES public.delegations(id);


--
-- Name: workflows fk_rails_ad47ad12fc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflows
    ADD CONSTRAINT fk_rails_ad47ad12fc FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: filter_sets fk_rails_afb3012934; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filter_sets
    ADD CONSTRAINT fk_rails_afb3012934 FOREIGN KEY (responsible_delegation_id) REFERENCES public.delegations(id);


--
-- Name: meta_data_roles fk_rails_b1e57448c0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meta_data_roles
    ADD CONSTRAINT fk_rails_b1e57448c0 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: context_keys fk_rails_b297363c89; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.context_keys
    ADD CONSTRAINT fk_rails_b297363c89 FOREIGN KEY (context_id) REFERENCES public.contexts(id);


--
-- Name: delegations_users fk_rails_b5f7f9c898; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delegations_users
    ADD CONSTRAINT fk_rails_b5f7f9c898 FOREIGN KEY (delegation_id) REFERENCES public.delegations(id);


--
-- Name: collection_group_permissions fk_rails_b88fcbe505; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_group_permissions
    ADD CONSTRAINT fk_rails_b88fcbe505 FOREIGN KEY (group_id) REFERENCES public.groups(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: media_entries fk_rails_b97d1d811d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_entries
    ADD CONSTRAINT fk_rails_b97d1d811d FOREIGN KEY (responsible_delegation_id) REFERENCES public.delegations(id);


--
-- Name: media_entry_group_permissions fk_rails_c5e91a50bb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_entry_group_permissions
    ADD CONSTRAINT fk_rails_c5e91a50bb FOREIGN KEY (group_id) REFERENCES public.groups(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: collection_user_permissions fk_rails_c83ae69464; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_user_permissions
    ADD CONSTRAINT fk_rails_c83ae69464 FOREIGN KEY (delegation_id) REFERENCES public.delegations(id);


--
-- Name: filter_set_user_permissions fk_rails_db103dd649; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filter_set_user_permissions
    ADD CONSTRAINT fk_rails_db103dd649 FOREIGN KEY (delegation_id) REFERENCES public.delegations(id);


--
-- Name: io_mappings fk_rails_dbf6e7c067; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.io_mappings
    ADD CONSTRAINT fk_rails_dbf6e7c067 FOREIGN KEY (meta_key_id) REFERENCES public.meta_keys(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: delegations_users fk_rails_df1fb72b34; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delegations_users
    ADD CONSTRAINT fk_rails_df1fb72b34 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: meta_data fk_rails_ee76aad01f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meta_data
    ADD CONSTRAINT fk_rails_ee76aad01f FOREIGN KEY (meta_key_id) REFERENCES public.meta_keys(id) ON UPDATE CASCADE;


--
-- Name: api_tokens fk_rails_f16b5e0447; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_tokens
    ADD CONSTRAINT fk_rails_f16b5e0447 FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: keywords fk_rails_f3e1612c9e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.keywords
    ADD CONSTRAINT fk_rails_f3e1612c9e FOREIGN KEY (meta_key_id) REFERENCES public.meta_keys(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: collections fk_rails_f465012c79; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT fk_rails_f465012c79 FOREIGN KEY (default_context_id) REFERENCES public.contexts(id) ON DELETE SET NULL;


--
-- Name: delegations_groups fk_rails_f6b29853e0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delegations_groups
    ADD CONSTRAINT fk_rails_f6b29853e0 FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: filter_set_user_permissions fk_rails_fe38b294ce; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filter_set_user_permissions
    ADD CONSTRAINT fk_rails_fe38b294ce FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: media_entry_user_permissions fk_rails_fef198d897; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_entry_user_permissions
    ADD CONSTRAINT fk_rails_fef198d897 FOREIGN KEY (delegation_id) REFERENCES public.delegations(id);


--
-- Name: groups_users groups-users_users_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups_users
    ADD CONSTRAINT "groups-users_users_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: io_mappings io-mappings_io-interfaces_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.io_mappings
    ADD CONSTRAINT "io-mappings_io-interfaces_fkey" FOREIGN KEY (io_interface_id) REFERENCES public.io_interfaces(id) ON DELETE CASCADE;


--
-- Name: keywords keywords_rdf_class_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.keywords
    ADD CONSTRAINT keywords_rdf_class_fkey FOREIGN KEY (rdf_class) REFERENCES public.rdf_classes(id) ON UPDATE CASCADE;


--
-- Name: media_entries media-entries_creators_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_entries
    ADD CONSTRAINT "media-entries_creators_fkey" FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: media_entries media-entries_responsible-users_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_entries
    ADD CONSTRAINT "media-entries_responsible-users_fkey" FOREIGN KEY (responsible_user_id) REFERENCES public.users(id);


--
-- Name: media_entry_api_client_permissions media-entry-api-client-permissions_api-clients_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_entry_api_client_permissions
    ADD CONSTRAINT "media-entry-api-client-permissions_api-clients_fkey" FOREIGN KEY (api_client_id) REFERENCES public.api_clients(id) ON DELETE CASCADE;


--
-- Name: media_entry_api_client_permissions media-entry-api-client-permissions_media-entries_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_entry_api_client_permissions
    ADD CONSTRAINT "media-entry-api-client-permissions_media-entries_fkey" FOREIGN KEY (media_entry_id) REFERENCES public.media_entries(id) ON DELETE CASCADE;


--
-- Name: media_entry_api_client_permissions media-entry-api-client-permissions_updators_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_entry_api_client_permissions
    ADD CONSTRAINT "media-entry-api-client-permissions_updators_fkey" FOREIGN KEY (updator_id) REFERENCES public.users(id);


--
-- Name: media_entry_group_permissions media-entry-group-permissions_media-entries_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_entry_group_permissions
    ADD CONSTRAINT "media-entry-group-permissions_media-entries_fkey" FOREIGN KEY (media_entry_id) REFERENCES public.media_entries(id) ON DELETE CASCADE;


--
-- Name: media_entry_group_permissions media-entry-group-permissions_updators_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_entry_group_permissions
    ADD CONSTRAINT "media-entry-group-permissions_updators_fkey" FOREIGN KEY (updator_id) REFERENCES public.users(id);


--
-- Name: media_entry_user_permissions media-entry-user-permissions_media-entries_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_entry_user_permissions
    ADD CONSTRAINT "media-entry-user-permissions_media-entries_fkey" FOREIGN KEY (media_entry_id) REFERENCES public.media_entries(id) ON DELETE CASCADE;


--
-- Name: media_entry_user_permissions media-entry-user-permissions_updators_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_entry_user_permissions
    ADD CONSTRAINT "media-entry-user-permissions_updators_fkey" FOREIGN KEY (updator_id) REFERENCES public.users(id);


--
-- Name: media_entry_user_permissions media-entry-user-permissions_users_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_entry_user_permissions
    ADD CONSTRAINT "media-entry-user-permissions_users_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: media_files media-files_media-entries_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_files
    ADD CONSTRAINT "media-files_media-entries_fkey" FOREIGN KEY (media_entry_id) REFERENCES public.media_entries(id);


--
-- Name: media_files media-files_uploaders_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_files
    ADD CONSTRAINT "media-files_uploaders_fkey" FOREIGN KEY (uploader_id) REFERENCES public.users(id);


--
-- Name: meta_data_keywords meta-data-keywords_keywords_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meta_data_keywords
    ADD CONSTRAINT "meta-data-keywords_keywords_fkey" FOREIGN KEY (keyword_id) REFERENCES public.keywords(id) ON DELETE CASCADE;


--
-- Name: meta_data_keywords meta-data-keywords_users_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meta_data_keywords
    ADD CONSTRAINT "meta-data-keywords_users_fkey" FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: meta_data_meta_terms meta-data-meta-terms_meta-data_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meta_data_meta_terms
    ADD CONSTRAINT "meta-data-meta-terms_meta-data_fkey" FOREIGN KEY (meta_datum_id) REFERENCES public.meta_data(id) ON DELETE CASCADE;


--
-- Name: meta_data_people meta-data-people_meta-data_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meta_data_people
    ADD CONSTRAINT "meta-data-people_meta-data_fkey" FOREIGN KEY (meta_datum_id) REFERENCES public.meta_data(id) ON DELETE CASCADE;


--
-- Name: meta_data_people meta-data-people_people_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meta_data_people
    ADD CONSTRAINT "meta-data-people_people_fkey" FOREIGN KEY (person_id) REFERENCES public.people(id);


--
-- Name: meta_data_people meta-data-people_users_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meta_data_people
    ADD CONSTRAINT "meta-data-people_users_fkey" FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: meta_data meta-data_collections_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meta_data
    ADD CONSTRAINT "meta-data_collections_fkey" FOREIGN KEY (collection_id) REFERENCES public.collections(id) ON DELETE CASCADE;


--
-- Name: meta_data meta-data_filter-sets_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meta_data
    ADD CONSTRAINT "meta-data_filter-sets_fkey" FOREIGN KEY (filter_set_id) REFERENCES public.filter_sets(id) ON DELETE CASCADE;


--
-- Name: meta_data meta-data_media-entries_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meta_data
    ADD CONSTRAINT "meta-data_media-entries_fkey" FOREIGN KEY (media_entry_id) REFERENCES public.media_entries(id) ON DELETE CASCADE;


--
-- Name: meta_data meta-data_users_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meta_data
    ADD CONSTRAINT "meta-data_users_fkey" FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: meta_keys meta-keys_vocabularies_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meta_keys
    ADD CONSTRAINT "meta-keys_vocabularies_fkey" FOREIGN KEY (vocabulary_id) REFERENCES public.vocabularies(id) ON DELETE CASCADE;


--
-- Name: meta_data_keywords meta_data_keywords_meta-data_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meta_data_keywords
    ADD CONSTRAINT "meta_data_keywords_meta-data_fkey" FOREIGN KEY (meta_datum_id) REFERENCES public.meta_data(id) ON DELETE CASCADE;


--
-- Name: meta_keys meta_keys_allowed_rdf_class_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meta_keys
    ADD CONSTRAINT meta_keys_allowed_rdf_class_fkey FOREIGN KEY (allowed_rdf_class) REFERENCES public.rdf_classes(id) ON UPDATE CASCADE;


--
-- Name: previews previews_media-files_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.previews
    ADD CONSTRAINT "previews_media-files_fkey" FOREIGN KEY (media_file_id) REFERENCES public.media_files(id) ON DELETE CASCADE;


--
-- Name: roles roles_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: users users_people_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_people_fkey FOREIGN KEY (person_id) REFERENCES public.people(id);


--
-- Name: visualizations visualizations_users_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visualizations
    ADD CONSTRAINT visualizations_users_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: vocabulary_api_client_permissions vocabulary-api-client-permissions_api-clients_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_api_client_permissions
    ADD CONSTRAINT "vocabulary-api-client-permissions_api-clients_fkey" FOREIGN KEY (api_client_id) REFERENCES public.api_clients(id) ON DELETE CASCADE;


--
-- Name: vocabulary_api_client_permissions vocabulary-api-client-permissions_vocabularies_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_api_client_permissions
    ADD CONSTRAINT "vocabulary-api-client-permissions_vocabularies_fkey" FOREIGN KEY (vocabulary_id) REFERENCES public.vocabularies(id) ON DELETE CASCADE;


--
-- Name: vocabulary_group_permissions vocabulary-group-permissions_vocabularies_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_group_permissions
    ADD CONSTRAINT "vocabulary-group-permissions_vocabularies_fkey" FOREIGN KEY (vocabulary_id) REFERENCES public.vocabularies(id) ON DELETE CASCADE;


--
-- Name: vocabulary_user_permissions vocabulary-user-permissions_users_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_user_permissions
    ADD CONSTRAINT "vocabulary-user-permissions_users_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: vocabulary_user_permissions vocabulary-user-permissions_vocabularies_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_user_permissions
    ADD CONSTRAINT "vocabulary-user-permissions_vocabularies_fkey" FOREIGN KEY (vocabulary_id) REFERENCES public.vocabularies(id) ON DELETE CASCADE;


--
-- Name: zencoder_jobs zencoder-jobs_media-files_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zencoder_jobs
    ADD CONSTRAINT "zencoder-jobs_media-files_fkey" FOREIGN KEY (media_file_id) REFERENCES public.media_files(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('0'),
('1'),
('10'),
('100'),
('101'),
('102'),
('103'),
('104'),
('105'),
('107'),
('108'),
('109'),
('11'),
('110'),
('111'),
('112'),
('113'),
('114'),
('115'),
('117'),
('118'),
('119'),
('12'),
('120'),
('121'),
('122'),
('123'),
('124'),
('125'),
('126'),
('127'),
('128'),
('129'),
('13'),
('130'),
('131'),
('132'),
('133'),
('134'),
('135'),
('136'),
('137'),
('138'),
('139'),
('14'),
('140'),
('141'),
('142'),
('143'),
('144'),
('145'),
('146'),
('147'),
('148'),
('149'),
('15'),
('150'),
('151'),
('152'),
('153'),
('154'),
('156'),
('157'),
('16'),
('165'),
('166'),
('168'),
('169'),
('17'),
('171'),
('175'),
('176'),
('177'),
('178'),
('18'),
('180'),
('181'),
('182'),
('183'),
('184'),
('185'),
('186'),
('187'),
('188'),
('189'),
('19'),
('190'),
('191'),
('192'),
('193'),
('194'),
('199'),
('2'),
('20'),
('200'),
('201'),
('202'),
('203'),
('204'),
('205'),
('206'),
('207'),
('208'),
('209'),
('21'),
('210'),
('211'),
('212'),
('213'),
('214'),
('215'),
('22'),
('23'),
('24'),
('25'),
('26'),
('27'),
('28'),
('29'),
('299'),
('3'),
('30'),
('300'),
('301'),
('302'),
('303'),
('304'),
('305'),
('306'),
('31'),
('310'),
('311'),
('312'),
('313'),
('314'),
('315'),
('316'),
('317'),
('318'),
('319'),
('32'),
('320'),
('321'),
('322'),
('323'),
('324'),
('325'),
('326'),
('327'),
('328'),
('329'),
('33'),
('330'),
('331'),
('332'),
('333'),
('334'),
('335'),
('336'),
('337'),
('338'),
('339'),
('34'),
('340'),
('341'),
('342'),
('343'),
('344'),
('345'),
('346'),
('347'),
('348'),
('349'),
('35'),
('350'),
('351'),
('352'),
('353'),
('354'),
('355'),
('356'),
('357'),
('358'),
('359'),
('360'),
('361'),
('362'),
('363'),
('364'),
('365'),
('366'),
('367'),
('368'),
('369'),
('370'),
('371'),
('372'),
('373'),
('374'),
('375'),
('376'),
('377'),
('378'),
('379'),
('380'),
('381'),
('382'),
('383'),
('384'),
('385'),
('386'),
('387'),
('388'),
('389'),
('390'),
('391'),
('392'),
('393'),
('394'),
('395'),
('396'),
('397'),
('398'),
('399'),
('4'),
('400'),
('401'),
('402'),
('403'),
('404'),
('405'),
('406'),
('407'),
('408'),
('409'),
('410'),
('411'),
('412'),
('413'),
('414'),
('415'),
('5'),
('6'),
('7'),
('8'),
('9');


