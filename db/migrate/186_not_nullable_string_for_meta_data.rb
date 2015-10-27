class NotNullableStringForMetaData < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
          CREATE OR REPLACE FUNCTION check_meta_datum_text_string_not_null()
          RETURNS TRIGGER AS $$
          BEGIN
            IF ((NEW.type = 'MetaDatum::Text' OR NEW.type = 'MetaDatum::TextDate')
                AND NEW.string IS NULL) THEN
              RAISE EXCEPTION 'String can not be NULL for type MetaDatum::Text or MetaDatum::TextDate';
            END IF;
            RETURN NEW;
          END;
          $$ language 'plpgsql';
        SQL

        execute <<-SQL
          CREATE CONSTRAINT TRIGGER trigger_check_meta_datum_text_string_not_null
          AFTER INSERT OR UPDATE
          ON meta_data
          INITIALLY DEFERRED
          FOR EACH ROW
          EXECUTE PROCEDURE check_meta_datum_text_string_not_null()
        SQL
      end

      dir.down do
        execute <<-SQL
          DROP TRIGGER trigger_check_meta_datum_text_string_not_null
          ON meta_data
        SQL

        execute <<-SQL
          DROP FUNCTION check_meta_datum_text_string_not_null
        SQL
      end
    end
  end
end
