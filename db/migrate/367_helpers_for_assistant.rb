class HelpersForAssistant < ActiveRecord::Migration[4.2]

  def up
    execute <<-SQL
      CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
    SQL
    execute <<-SQL
      CREATE OR REPLACE FUNCTION person_display_name(first_name varchar, last_name varchar, pseudonym varchar)
      RETURNS varchar AS $$
        BEGIN RETURN (CASE
                          WHEN ((first_name <> ''
                                 OR last_name <> '')
                                AND pseudonym <> '') THEN btrim(first_name || ' ' || last_name || ' ' || '(' || pseudonym || ')')
                          WHEN (first_name <> ''
                                OR last_name <> '') THEN btrim(first_name || ' ' || last_name)
                          ELSE btrim(pseudonym)
                      END);
        END;
      $$ LANGUAGE plpgsql;
    SQL
  end

  def down
    execute <<-SQL
      DROP EXTENSION IF EXISTS fuzzystrmatch;
    SQL
    execute <<-SQL
      DROP FUNCTION IF EXISTS person_display_name;
    SQL
  end
end
