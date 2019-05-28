class AllowDraftsInSetsOfWorkflow < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL.strip_heredoc
      CREATE OR REPLACE FUNCTION check_no_drafts_in_collections()
      RETURNS trigger AS $$
      BEGIN
        IF
          (SELECT is_published FROM media_entries WHERE id = NEW.media_entry_id) = false
          AND NOT EXISTS (
            SELECT 1 FROM workflows WHERE workflows.is_active = TRUE AND workflows.id IN (
              SELECT workflow_id FROM collections WHERE collections.id IN (
                #{collection_ids}
              )
            )
          )
          THEN RAISE EXCEPTION 'Incomplete MediaEntries can not be put into Collections!';
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL
  end

  private

  def collection_ids
    <<-SQL.strip_heredoc
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
    SQL
  end
end
