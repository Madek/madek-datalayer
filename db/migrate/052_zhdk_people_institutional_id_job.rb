class ZhdkPeopleInstitutionalIdJob < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL
      DO $$
      DECLARE
        bad_rows_count INT;
      BEGIN
        -- ZHdK only!
        IF (SELECT count(*) FROM app_settings WHERE copyright_notice_default_text = 'Zürcher Hochschule der Künste') = 0 THEN
          RETURN;
        END IF;

        -- Test for the "multiple user-institutional_id per person" problem
        SELECT count(*) INTO bad_rows_count 
          FROM (SELECT person_id FROM users GROUP BY person_id, institution HAVING count(DISTINCT institutional_id) > 1) AS subq;
        IF bad_rows_count > 0 THEN
          RAISE EXCEPTION 'Can not continue because there are % people rows which are referenced by multiple user rows having distinct institutional_id.', bad_rows_count;
        END IF;

        -- replace institution 'local' with 'zhdk.ch' for user rows which have an institutional_id
        UPDATE users
        SET institution = 'zhdk.ch'
        WHERE
          institution = 'local'
          AND institutional_id IS NOT NULL;

        -- copy institution/institutional_id from user to person
        UPDATE people
        SET institution = users.institution,
            institutional_id = users.institutional_id
        FROM users
        WHERE
          users.person_id = people.id
          AND users.institutional_id IS NOT NULL;
      END
      $$;    
    SQL
  end
end
