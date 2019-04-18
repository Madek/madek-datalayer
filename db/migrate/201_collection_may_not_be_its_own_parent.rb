class CollectionMayNotBeItsOwnParent < ActiveRecord::Migration[4.2]
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
          CREATE OR REPLACE FUNCTION collection_may_not_be_its_own_parent()
          RETURNS TRIGGER AS $$
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
          $$ language 'plpgsql';
        SQL

        execute <<-SQL
          CREATE CONSTRAINT TRIGGER trigger_collection_may_not_be_its_own_parent
          AFTER INSERT OR UPDATE
          ON collection_collection_arcs
          INITIALLY DEFERRED
          FOR EACH ROW
          EXECUTE PROCEDURE collection_may_not_be_its_own_parent()
        SQL
      end

      dir.down do
        execute <<-SQL
          DROP TRIGGER trigger_collection_may_not_be_its_own_parent ON collection_collection_arcs
        SQL

        execute <<-SQL
          DROP FUNCTION IF EXISTS collection_may_not_be_its_own_parent()
        SQL
      end
    end
  end
end
