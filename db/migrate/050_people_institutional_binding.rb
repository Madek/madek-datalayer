class PeopleInstitutionalBinding < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL
      CREATE OR REPLACE FUNCTION check_user_to_person_institutional_id_consistency() RETURNS TRIGGER AS $$
      BEGIN
        -- An institutional user must reference a matching institutional person
        IF NEW.institution <> 'local' THEN
          IF NEW.institutional_id IS NULL THEN
            RAISE EXCEPTION 'user of non-local institution ''%'' must have a NON NULL institutional_id', NEW.institution;
          END IF;

          PERFORM 1
          FROM people
          WHERE people.id = NEW.person_id
          AND people.institution = NEW.institution
          AND people.institutional_id = NEW.institutional_id;

          IF NOT FOUND THEN
            RAISE EXCEPTION 'Institutional ID mismatch: institutional_id ''%'' / ''%'' of user  is not consistent with related person (person_id = %)',
              NEW.institution, NEW.institutional_id, NEW.person_id;
          END IF;
        END IF;

        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER trigger_check_user_to_person_institutional_id_consistency
      BEFORE INSERT OR UPDATE ON users
      FOR EACH ROW
      EXECUTE FUNCTION check_user_to_person_institutional_id_consistency();

      CREATE OR REPLACE FUNCTION check_person_to_user_institutional_id_consistency() RETURNS TRIGGER AS $$
      BEGIN
        -- When a matching institutional user references for this person, the institutional id of the person must not be modified
        IF OLD.institution <> 'local' AND (
          NEW.institution IS DISTINCT FROM OLD.institution OR NEW.institutional_id IS DISTINCT FROM OLD.institutional_id
        ) THEN
          PERFORM 1
          FROM users
          WHERE users.person_id = NEW.id
            AND users.institution = OLD.institution
            AND users.institutional_id = OLD.institutional_id;

          IF FOUND THEN
            RAISE EXCEPTION 'Institutional ID mismatch: institutional_id ''%'' / ''%'' of person must not be modified in order to remain consistent with related user',
              OLD.institution, OLD.institutional_id;
          END IF;
        END IF;

        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;


      CREATE TRIGGER trigger_check_person_to_user_institutional_id_consistency
      BEFORE UPDATE ON people
      FOR EACH ROW
      EXECUTE FUNCTION check_person_to_user_institutional_id_consistency();
    SQL
  end

  def down
    execute <<~SQL
      DROP TRIGGER IF EXISTS trigger_check_person_to_user_institutional_id_consistency ON people;
      DROP FUNCTION IF EXISTS check_person_to_user_institutional_id_consistency;

      DROP TRIGGER IF EXISTS trigger_check_user_to_person_institutional_id_consistency ON users;
      DROP FUNCTION IF EXISTS check_user_to_person_institutional_id_consistency;
    SQL
  end
end
