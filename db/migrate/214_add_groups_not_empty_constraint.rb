class AddGroupsNotEmptyConstraint < ActiveRecord::Migration[4.2]
  def change

    reversible do |dir|
      dir.up do
        execute <<-SQL
          CREATE OR REPLACE FUNCTION delete_empty_group_after_delete_join()
          RETURNS TRIGGER AS $$
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
          $$ language 'plpgsql';
        SQL

        execute <<-SQL
          CREATE CONSTRAINT TRIGGER trigger_delete_empty_group_after_delete_join
          AFTER DELETE
          ON groups_users
          INITIALLY DEFERRED
          FOR EACH ROW
          EXECUTE PROCEDURE delete_empty_group_after_delete_join()
        SQL
      end

      dir.down do
        execute %( DROP TRIGGER trigger_delete_empty_group_after_delete_join ON groups_users )
        execute %{ DROP FUNCTION IF EXISTS delete_empty_group_after_delete_join() }
      end
    end
  end
end
