CREATE OR REPLACE FUNCTION public.readonly_core_meta_key_columns_unchanged(old meta_keys, new meta_keys)
RETURNS bool
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN (
    new.id                           IS NOT DISTINCT FROM old.id AND
    new.is_extensible_list           IS NOT DISTINCT FROM old.is_extensible_list AND
    new.meta_datum_object_type       IS NOT DISTINCT FROM old.meta_datum_object_type AND
    new.keywords_alphabetical_order  IS NOT DISTINCT FROM old.keywords_alphabetical_order AND
    new.position                     IS NOT DISTINCT FROM old.position AND
    new.is_enabled_for_media_entries IS NOT DISTINCT FROM old.is_enabled_for_media_entries AND
    new.is_enabled_for_collections   IS NOT DISTINCT FROM old.is_enabled_for_collections AND
    new.vocabulary_id                IS NOT DISTINCT FROM old.vocabulary_id AND
    new.admin_comment                IS NOT DISTINCT FROM old.admin_comment AND
    new.allowed_people_subtypes      IS NOT DISTINCT FROM old.allowed_people_subtypes AND
    new.text_type                    IS NOT DISTINCT FROM old.text_type AND
    new.allowed_rdf_class            IS NOT DISTINCT FROM old.allowed_rdf_class
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.check_madek_core_meta_key_immutability()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    IF (OLD.id ilike 'madek_core:%') THEN
      RAISE EXCEPTION 'The madek_core meta_key % may not be deleted', OLD.id;
    END IF;
  ELSIF (TG_OP = 'UPDATE') THEN
    IF (OLD.id ilike 'madek_core:%' AND NOT readonly_core_meta_key_columns_unchanged(OLD, NEW)) THEN
      RAISE EXCEPTION 'Only certain attributes of madek_core meta_key % may be modified', OLD.id;
    END IF;
  ELSIF  (TG_OP = 'INSERT') THEN
    IF (NEW.id ilike 'madek_core:%') THEN
      RAISE EXCEPTION 'The madek_core meta_key namespace may not be extended by %', NEW.id;
    END IF;
  END IF;
  RETURN NEW;
END;
$function$
