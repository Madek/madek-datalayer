# UNION de-duplicates: Postgres hash-aggregates every row of media_entries and
# collections before an `id IN (...)` filter on the view applies, so set pages
# with child sets scale with the whole database, not with the set.
#
# The branches can never overlap (each has its own `type` literal, and `id` is
# each table's primary key), so UNION ALL returns the same rows and lets
# Postgres apply the filter per branch. Only the unspecified row order may
# change; callers order explicitly.
class VwMediaResourcesUnionAll < ActiveRecord::Migration[7.2]
  def view_sql(set_operator)
    <<~SQL
      CREATE OR REPLACE VIEW public.vw_media_resources
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
      #{set_operator}
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

  def up
    execute view_sql('UNION ALL')
  end

  def down
    execute view_sql('UNION')
  end
end
