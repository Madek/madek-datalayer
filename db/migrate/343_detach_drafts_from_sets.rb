class DetachDraftsFromSets < ActiveRecord::Migration[4.2]
  def change

    execute <<-SQL.strip_heredoc
      DELETE FROM collection_media_entry_arcs WHERE collection_media_entry_arcs IN (
      	SELECT DISTINCT collection_media_entry_arcs FROM collection_media_entry_arcs
        INNER JOIN media_entries ON media_entries.id = collection_media_entry_arcs.media_entry_id
        WHERE media_entries.is_published = false
      )
    SQL

    execute <<-SQL.strip_heredoc
      CREATE FUNCTION check_no_drafts_in_collections() RETURNS trigger
          LANGUAGE plpgsql
          AS $$
                BEGIN
                  IF
                    (SELECT is_published FROM media_entries WHERE id = NEW.media_entry_id) = false
                    THEN RAISE EXCEPTION 'Incomplete MediaEntries can not be put into Collections!';
                  END IF;
                  RETURN NEW;
                END;
                $$;

      CREATE CONSTRAINT TRIGGER trigger_check_no_drafts_in_collections
        AFTER INSERT OR UPDATE ON collection_media_entry_arcs
        DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE
        PROCEDURE check_no_drafts_in_collections();
    SQL
  end
end
