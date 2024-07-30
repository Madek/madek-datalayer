class VwMediaResourcesResponsibleDelegationId < ActiveRecord::Migration[6.1]

  def up
    execute <<-SQL.strip_heredoc
      DROP VIEW IF EXISTS vw_media_resources;
      CREATE VIEW public.vw_media_resources
      AS
      SELECT media_entries.id,
          media_entries.get_metadata_and_previews,
          media_entries.responsible_user_id,
          media_entries.responsible_delegation_id,
          media_entries.creator_id,
          media_entries.created_at,
          media_entries.updated_at,
          'MediaEntry'::text AS type
        FROM media_entries
      UNION
      SELECT collections.id,
          collections.get_metadata_and_previews,
          collections.responsible_user_id,
          collections.responsible_delegation_id,
          collections.creator_id,
          collections.created_at,
          collections.updated_at,
          'Collection'::text AS type
        FROM collections;
    SQL
  end

  def down
  end

end

