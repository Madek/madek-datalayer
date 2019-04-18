class OnlyOneCoverForCollectionCheck < ActiveRecord::Migration[4.2]
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
          CREATE OR REPLACE FUNCTION check_collection_cover_uniqueness()
          RETURNS TRIGGER AS $$
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
          $$ language 'plpgsql';
        SQL

        execute <<-SQL
          CREATE CONSTRAINT TRIGGER trigger_check_collection_cover_uniqueness
          AFTER INSERT OR UPDATE
          ON collection_media_entry_arcs
          INITIALLY DEFERRED
          FOR EACH ROW
          EXECUTE PROCEDURE check_collection_cover_uniqueness()
        SQL
      end

      dir.down do
        execute <<-SQL
          DROP TRIGGER trigger_check_collection_cover_uniqueness
          ON collection_media_entry_arcs
        SQL

        execute <<-SQL
          DROP FUNCTION check_collection_cover_uniqueness
        SQL
      end
    end
  end
end
