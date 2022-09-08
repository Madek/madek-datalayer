class DropFilterSets < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL

      DROP FUNCTION IF EXISTS check_filter_set_primary_uniqueness CASCADE;
      DROP FUNCTION IF EXISTS propagate_edit_session_insert_to_filter_sets CASCADE;

      ALTER TABLE custom_urls DROP COLUMN filter_set_id CASCADE;

      ALTER TABLE edit_sessions DROP COLUMN filter_set_id CASCADE;
      DELETE FROM edit_sessions WHERE collection_id IS NULL AND  media_entry_id IS NULL;
      ALTER TABLE edit_sessions ADD CONSTRAINT edit_sessions_is_related
        CHECK ((((media_entry_id IS NOT NULL) AND (collection_id IS NULL)) OR ((media_entry_id IS NULL) AND (collection_id IS NOT NULL))));

      ALTER TABLE meta_data DROP COLUMN filter_set_id CASCADE;
      ALTER TABLE meta_keys DROP COLUMN is_enabled_for_filter_sets CASCADE;


      DROP TABLE IF EXISTS collection_filter_set_arcs CASCADE;
      DROP TABLE IF EXISTS favorite_filter_sets CASCADE;
      DROP TABLE IF EXISTS filter_set_api_client_permissions CASCADE;
      DROP TABLE IF EXISTS filter_set_group_permissions CASCADE;
      DROP TABLE IF EXISTS filter_set_user_permissions CASCADE;
      DROP TABLE IF EXISTS filter_sets CASCADE;

      CREATE OR REPLACE FUNCTION public.propagate_meta_data_updates_to_media_resource() RETURNS trigger
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

        RETURN NULL;
      END;
      $$;


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
         FROM public.collections;

    SQL
  end
end
