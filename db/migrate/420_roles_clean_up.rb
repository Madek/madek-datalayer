class RolesCleanUp < ActiveRecord::Migration[5.2]
  def up

    execute <<-SQL

      DELETE FROM meta_data_roles
        WHERE
          meta_datum_id IS NULL
        OR
          (NOT EXISTS
            (SELECT true FROM meta_data WHERE meta_datum_id = meta_data.id))
        OR
          (role_id IS NOT NULL
            AND
            (NOT EXISTS
              (SELECT true FROM roles WHERE role_id = roles.id)))
        OR
          (NOT EXISTS
            (SELECT true FROM people WHERE person_id = people.id));

      ALTER TABLE meta_data_roles ALTER COLUMN meta_datum_id SET NOT NULL;

      ALTER TABLE meta_data_roles ADD CONSTRAINT meta_data_roles_person_fkey
        FOREIGN KEY (person_id) REFERENCES people(id) ON DELETE CASCADE;

      ALTER TABLE meta_data_roles ADD CONSTRAINT meta_data_roles_meta_datum_fkey
        FOREIGN KEY (meta_datum_id) REFERENCES meta_data(id) ON DELETE CASCADE;

      ALTER TABLE meta_data_roles ADD CONSTRAINT meta_data_roles_role_fkey
        FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE;

      ALTER TABLE meta_data_roles DROP COLUMN IF EXISTS created_by_id CASCADE;

    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE meta_data_roles DROP CONSTRAINT meta_data_roles_person_fkey;
      ALTER TABLE meta_data_roles DROP CONSTRAINT meta_data_roles_meta_datum_fkey;
      ALTER TABLE meta_data_roles DROP CONSTRAINT meta_data_roles_role_fkey;
    SQL
  end
end
