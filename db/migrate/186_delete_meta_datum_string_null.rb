class DeleteMetaDatumStringNull < ActiveRecord::Migration[4.2]
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
          CREATE OR REPLACE FUNCTION delete_meta_datum_text_string_null()
          RETURNS TRIGGER AS $$
          BEGIN
            IF ((NEW.type = 'MetaDatum::Text' OR NEW.type = 'MetaDatum::TextDate')
                AND NEW.string IS NULL) THEN
              DELETE FROM meta_data WHERE meta_data.id = NEW.id;
            END IF;
            RETURN NEW;
          END;
          $$ language 'plpgsql';
        SQL

        execute <<-SQL
          CREATE CONSTRAINT TRIGGER trigger_delete_meta_datum_text_string_null
          AFTER INSERT OR UPDATE
          ON meta_data
          INITIALLY DEFERRED
          FOR EACH ROW
          EXECUTE PROCEDURE delete_meta_datum_text_string_null()
        SQL
      end

      dir.down do
        execute <<-SQL
          DROP TRIGGER trigger_delete_meta_datum_text_string_null
          ON meta_data
        SQL

        execute <<-SQL
          DROP FUNCTION delete_meta_datum_text_string_null
        SQL
      end
    end
  end
end
