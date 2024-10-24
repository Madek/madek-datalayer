class PersonUserConsistencyConstraint < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL
      CREATE OR REPLACE FUNCTION check_user_to_person_consistency() RETURNS TRIGGER AS $$
      BEGIN
        -- Related person must have subtype 'Person'
        IF EXISTS (
          SELECT 1
          FROM people
          WHERE people.id = NEW.person_id AND people.subtype <> 'Person'
        ) THEN
            RAISE EXCEPTION 'The related person must have subtype ''Person''';
        END IF;

        -- When user has an instutional id, it must reference the matching person
        IF NEW.institutional_id IS NOT NULL 
          AND EXISTS (SELECT 1 FROM people WHERE people.id = NEW.person_id) -- (bypass FK and 'NOT NULL' constraint because they checked on model level already)
          AND NOT EXISTS (
            SELECT 1
            FROM people
            WHERE people.id = NEW.person_id
            AND people.institution = NEW.institution
            AND people.institutional_id = NEW.institutional_id
          ) THEN
            RAISE EXCEPTION 'Institutional ID mismatch: institutional_id ''%'' / ''%'' of user  is not consistent with related person (person_id = %)',
              NEW.institution, NEW.institutional_id, NEW.person_id;
        END IF;

        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER trigger_check_user_to_person_consistency
      BEFORE INSERT OR UPDATE ON users
      FOR EACH ROW
      EXECUTE FUNCTION check_user_to_person_consistency();

      CREATE OR REPLACE FUNCTION check_person_to_user_consistency() RETURNS TRIGGER AS $$
      BEGIN
        -- Make sure an existing institutional reference from a user is not modified
        IF (NEW.institution IS DISTINCT FROM OLD.institution OR NEW.institutional_id IS DISTINCT FROM OLD.institutional_id)
          AND EXISTS (
            SELECT 1
            FROM users
            WHERE users.person_id = NEW.id
            AND users.institution = OLD.institution
            AND users.institutional_id = OLD.institutional_id
          ) THEN
            RAISE EXCEPTION 'Institutional ID mismatch: institutional_id ''%'' / ''%'' of person must not be modified in order to remain consistent with related user',
              OLD.institution, OLD.institutional_id;
        END IF;

        -- Make sure a person with a referencing user remains of subtype 'Person'
        IF NEW.subtype IS DISTINCT FROM OLD.subtype AND NEW.subtype <> 'Person'
          AND EXISTS (
            SELECT 1
            FROM users
            WHERE users.person_id = NEW.id
          ) THEN
            RAISE EXCEPTION 'Person subtype mismatch: person is related to a user and must keep subtype ''Person'' (attempted subtype: ''%'')',
              NEW.subtype;
        END IF;

        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;


      CREATE TRIGGER trigger_check_person_to_user_consistency
      BEFORE UPDATE ON people
      FOR EACH ROW
      EXECUTE FUNCTION check_person_to_user_consistency();
    SQL
  end

  def down
    execute <<~SQL
      DROP TRIGGER IF EXISTS trigger_check_person_to_user_consistency ON people;
      DROP FUNCTION IF EXISTS check_person_to_user_consistency;

      DROP TRIGGER IF EXISTS trigger_check_user_to_person_consistency ON users;
      DROP FUNCTION IF EXISTS check_user_to_person_consistency;
    SQL
  end
end
