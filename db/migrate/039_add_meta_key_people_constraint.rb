class AddMetaKeyPeopleConstraint < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL
      CREATE OR REPLACE FUNCTION check_allowed_people_subtypes_immutability_f()
      RETURNS TRIGGER AS $$
      BEGIN
        IF (
          OLD.allowed_people_subtypes <> NEW.allowed_people_subtypes
          AND OLD.meta_datum_object_type = 'MetaDatum::People'
          AND EXISTS (
            SELECT 1
            FROM meta_data
            WHERE meta_data.meta_key_id = OLD.id
          )
        ) THEN
          RAISE EXCEPTION 'Cannot change allowed_people_subtypes when meta_data is present';
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL

    execute <<~SQL
      CREATE TRIGGER check_allowed_people_subtypes_immutability_t
      BEFORE UPDATE ON meta_keys
      FOR EACH ROW EXECUTE FUNCTION check_allowed_people_subtypes_immutability_f();
    SQL

    execute <<~SQL
      ALTER TABLE meta_keys
      ADD CONSTRAINT check_allowed_people_subtypes_values
      CHECK (
        allowed_people_subtypes IS NULL
        OR allowed_people_subtypes <@ ARRAY['Person', 'PeopleGroup', 'PeopleInstitutionalGroup']
      )
    SQL

  end

  def down
    execute <<~SQL
      DROP TRIGGER IF EXISTS check_allowed_people_subtypes_immutability_t ON meta_keys;
      DROP FUNCTION IF EXISTS check_allowed_people_subtypes_immutability_f();
    SQL

    execute <<~SQL
      ALTER TABLE DROP CONSTRAINT check_allowed_people_subtypes_values;
    SQL
  end
end
