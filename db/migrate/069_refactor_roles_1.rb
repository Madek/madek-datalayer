class RefactorRoles1 < ActiveRecord::Migration[7.2]
  include Madek::MigrationHelper

  def up
    # Create roles_lists table
    # - labels: hstore field for storing localized role list names (e.g., {"en": "Administrators", "de": "Administratoren"})
    # - is_extensible_list: boolean flag indicating if additional roles can be added to this list by the webapp user
    create_table :roles_lists, id: :uuid do |t|
      t.hstore :labels, null: false, default: {}
      t.boolean :is_extensible_list, null: false, default: false
    end

    add_auto_timestamps :roles_lists, null: false

    # Add roles_list_id to meta_keys to link them with roles_lists
    add_column :meta_keys, :roles_list_id, :uuid, null: true
    add_foreign_key :meta_keys, :roles_lists, column: :roles_list_id

    # Add role_id to meta_data_people to link people with their roles
    # Create join table for many-to-many relationship between roles_lists and roles
    # This allows roles to belong to multiple lists and lists to contain multiple roles
    create_table :roles_lists_roles, id: :uuid do |t|
      t.uuid :roles_list_id, null: false
      t.uuid :role_id, null: false
    end
    add_auto_timestamps :roles_lists_roles, null: false, updated_at: false
    add_foreign_key :roles_lists_roles, :roles_lists, column: :roles_list_id
    add_foreign_key :roles_lists_roles, :roles, column: :role_id
    add_index :roles_lists_roles, [:roles_list_id, :role_id], unique: true

    # Create roles_lists for each meta_key that currently has MetaDatum::Roles type
    # Generate multilingual labels based on the meta_key id
    execute <<-SQL
      INSERT INTO roles_lists (labels)
      SELECT hstore(ARRAY['en', 'de'], ARRAY[meta_keys.id || ' Roles', meta_keys.id || ' Rollen']) as labels
      FROM meta_keys
      WHERE meta_keys.meta_datum_object_type = 'MetaDatum::Roles'
      AND EXISTS (
        SELECT 1 FROM roles WHERE roles.meta_key_id = meta_keys.id
      );
    SQL

    # Link meta_keys to their corresponding roles_lists
    # Match by the generated label pattern
    execute <<-SQL
      UPDATE meta_keys
      SET roles_list_id = roles_lists.id
      FROM roles_lists
      WHERE meta_keys.meta_datum_object_type = 'MetaDatum::Roles'
      AND roles_lists.labels->'en' = meta_keys.id || ' Roles';
    SQL

    # Populate the join table with existing role-to-meta_key relationships
    # This preserves the current role groupings under their new roles_lists
    execute <<-SQL
      INSERT INTO roles_lists_roles (roles_list_id, role_id)
      SELECT meta_keys.roles_list_id, roles.id
      FROM roles
      JOIN meta_keys ON meta_keys.id = roles.meta_key_id
      WHERE meta_keys.roles_list_id IS NOT NULL;
    SQL

    # Convert MetaDatum::Roles meta_keys to MetaDatum::People
    # This changes the data model from role-based to people-based with role associations
    execute <<-SQL
      UPDATE meta_keys 
      SET meta_datum_object_type = 'MetaDatum::People'
      WHERE meta_datum_object_type = 'MetaDatum::Roles'
    SQL

    # Convert existing MetaDatum::Roles instances to MetaDatum::People
    execute <<-SQL
      UPDATE meta_data 
      SET type = 'MetaDatum::People'
      WHERE type = 'MetaDatum::Roles'
    SQL

    # Update the index on meta_data_people to include role_id
    # This ensures uniqueness across the combination of metadata, person, and role
    remove_index :meta_data_people, name: "index_md_people_on_md_id_and_person_id"
    add_column :meta_data_people, :role_id, :uuid, null: true
    add_foreign_key :meta_data_people, :roles, column: :role_id

    execute <<-SQL
      CREATE UNIQUE INDEX index_md_people_on_md_id_person_id_and_role_id 
      ON meta_data_people (meta_datum_id, person_id, role_id) 
      WHERE role_id IS NOT NULL;
    SQL

    execute <<-SQL
      CREATE UNIQUE INDEX index_md_people_on_md_id_person_id_where_role_id_is_null 
      ON meta_data_people (meta_datum_id, person_id)
      WHERE role_id IS NULL;
    SQL

    # Migrate data from meta_data_roles to meta_data_people
    # This preserves all existing role assignments while converting to the new structure
    execute <<-SQL
      INSERT INTO meta_data_people (
        meta_datum_id,
        person_id,
        role_id,
        created_by_id,
        meta_data_updated_at,
        position
      )
      SELECT 
        meta_data_roles.meta_datum_id,
        meta_data_roles.person_id,
        meta_data_roles.role_id,
        meta_data.created_by_id,
        meta_data.meta_data_updated_at,
        meta_data_roles.position
      FROM meta_data_roles
      JOIN meta_data ON meta_data.id = meta_data_roles.meta_datum_id
    SQL

    # Clean up: remove the old tables and columns
    drop_table :meta_data_roles
    remove_column :roles, :meta_key_id
    add_index :roles, :labels, unique: true

    # Add constraint trigger to prevent removal of a role from a roles_list if it has been used in meta_data_people
    execute <<-SQL
      CREATE OR REPLACE FUNCTION prevent_role_removal_from_roles_list_f()
      RETURNS TRIGGER AS $$
      BEGIN
        IF EXISTS (
          SELECT 1 FROM meta_data_people 
          JOIN meta_data ON meta_data.id = meta_data_people.meta_datum_id
          JOIN meta_keys ON meta_keys.id = meta_data.meta_key_id
          WHERE meta_data_people.role_id = OLD.role_id
          AND meta_keys.roles_list_id = OLD.roles_list_id
        ) THEN
          RAISE EXCEPTION 'Cannot remove role from roles_list: role is currently used in MetaDatum::People records for this roles_list';
        END IF;
        RETURN OLD;
      END;
      $$ LANGUAGE plpgsql;

      CREATE CONSTRAINT TRIGGER check_role_not_used_in_meta_data_t
      AFTER DELETE ON roles_lists_roles
      DEFERRABLE INITIALLY DEFERRED
      FOR EACH ROW EXECUTE FUNCTION prevent_role_removal_from_roles_list_f();
    SQL

    # Add constraint trigger to prevent removal of roles_list from meta_keys if it has been used
    execute <<-SQL
      CREATE OR REPLACE FUNCTION prevent_roles_list_removal_from_meta_key_f()
      RETURNS TRIGGER AS $$
      BEGIN
        IF OLD.roles_list_id IS NOT NULL AND OLD.roles_list_id != NEW.roles_list_id THEN
          IF EXISTS (
            SELECT 1 FROM meta_data 
            WHERE meta_data.meta_key_id = OLD.id 
            AND meta_data.type = 'MetaDatum::People'
          ) THEN
            RAISE EXCEPTION 'Cannot change roles_list for meta_key: meta_key is currently used in MetaDatum::People records';
          END IF;
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;

      CREATE CONSTRAINT TRIGGER check_roles_list_not_used_when_removed_t
      AFTER UPDATE ON meta_keys
      DEFERRABLE INITIALLY DEFERRED
      FOR EACH ROW EXECUTE FUNCTION prevent_roles_list_removal_from_meta_key_f();
    SQL

    # Add constraint trigger to validate that role_id belongs to the roles_list associated with the meta_key
    execute <<-SQL
      CREATE OR REPLACE FUNCTION validate_role_belongs_to_meta_key_roles_list_f()
      RETURNS TRIGGER AS $$
      BEGIN
        IF NEW.role_id IS NOT NULL THEN
          IF NOT EXISTS (
            SELECT 1 FROM meta_data
            JOIN meta_keys ON meta_keys.id = meta_data.meta_key_id
            JOIN roles_lists_roles ON roles_lists_roles.roles_list_id = meta_keys.roles_list_id
            WHERE meta_data.id = NEW.meta_datum_id
            AND roles_lists_roles.role_id = NEW.role_id
          ) THEN
            RAISE EXCEPTION 'Role does not belong to the roles_list associated with this meta_key';
          END IF;
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;

      CREATE CONSTRAINT TRIGGER check_role_belongs_to_meta_key_roles_list_t
      AFTER INSERT OR UPDATE ON meta_data_people
      DEFERRABLE INITIALLY DEFERRED
      FOR EACH ROW EXECUTE FUNCTION validate_role_belongs_to_meta_key_roles_list_f();
    SQL

    # Example query to verify the migration results:
    # This query shows the relationships between meta_keys, roles_lists, and roles
    # after the migration is complete. It demonstrates how to traverse the new
    # many-to-many relationship structure.
    #
    # SELECT meta_keys.id,
    #        roles_lists.labels->'en' AS roles_list_label_en,
    #        roles.labels->'en' AS role_label_en,
    #        roles.labels->'de' AS role_label_de
    # FROM meta_keys
    # JOIN roles_lists ON meta_keys.roles_list_id = roles_lists.id
    # JOIN roles_lists_roles ON roles_lists.id = roles_lists_roles.roles_list_id
    # JOIN roles ON roles_lists_roles.role_id = roles.id
    # WHERE meta_keys.roles_list_id IS NOT NULL
    # ORDER BY roles.labels->'en';
  end
end
