class MetaDatumUpdatedAtOnPeople < ActiveRecord::Migration[4.2]
  def change

    reversible do |dir|
      dir.up do
        execute <<-SQL.strip_heredoc
          ALTER TABLE meta_data ADD COLUMN meta_data_updated_at timestamp with time zone DEFAULT now() NOT NULL;
          ALTER TABLE meta_data_people ADD COLUMN meta_data_updated_at timestamp with time zone DEFAULT now() NOT NULL;
        SQL

        execute <<-SQL.strip_heredoc
          CREATE OR REPLACE FUNCTION propagate_meta_data_people_updates_to_meta_data()
          RETURNS TRIGGER AS $$
          DECLARE
            md_id UUID;
          BEGIN
            CASE
              WHEN TG_OP = 'DELETE' THEN
                md_id = OLD.meta_datum_id;
              ELSE
                md_id = NEW.meta_datum_id;
            END CASE;

            UPDATE meta_data
              SET meta_data_updated_at = now()
              WHERE meta_data.id = md_id;
            RETURN NULL;
          END;
          $$ language 'plpgsql';

          CREATE TRIGGER propagate_meta_data_people_updates_to_meta_data
            AFTER INSERT OR DELETE OR UPDATE
            ON meta_data_people
            FOR EACH ROW EXECUTE PROCEDURE propagate_meta_data_people_updates_to_meta_data();
        SQL

        execute <<-SQL.strip_heredoc
          CREATE OR REPLACE FUNCTION propagate_people_updates_to_meta_data_people()
          RETURNS TRIGGER AS $$
          BEGIN
            UPDATE meta_data_people
              SET meta_data_updated_at = now()
              WHERE person_id = NEW.id;
            RETURN NULL;
          END;
          $$ language 'plpgsql';

          CREATE TRIGGER propagate_people_updates_to_meta_data_people
            AFTER INSERT OR UPDATE
            ON people
            FOR EACH ROW EXECUTE PROCEDURE propagate_people_updates_to_meta_data_people();
        SQL



      end
      dir.down do
        execute <<-SQL.strip_heredoc
          DROP TRIGGER propagate_people_updates_to_meta_data_people;
          DROP FUNCTION propagate_people_updates_to_meta_data_people();
          DROP TRIGGER propagate_meta_data_people_updates_to_meta_data ON meta_data_people;
          DROP FUNCTION propagate_meta_data_people_updates_to_meta_data();
          ALTER TABLE meta_data DROP COLUMN meta_data_updated_at CASCADE;
          ALTER TABLE meta_data_people DROP COLUMN meta_data_updated_at CASCADE;
        SQL
      end
    end


  end
end
