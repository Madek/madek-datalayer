class CheckSingleKeywordSelection < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL
      CREATE OR REPLACE FUNCTION check_single_keyword_selection_f()
      RETURNS TRIGGER AS $$
      BEGIN
        IF (
          SELECT meta_keys.multiple_selection
          FROM meta_data
          INNER JOIN meta_keys ON meta_keys.id = meta_data.meta_key_id
          WHERE meta_data.id = NEW.meta_datum_id  
        ) = FALSE
        AND (
          SELECT COUNT(*)
          FROM meta_data_keywords
          WHERE meta_datum_id = NEW.meta_datum_id
        ) > 1 
        THEN
          RAISE EXCEPTION 'Cannot assign multiple keywords when multiple selection is disallowed for meta key';
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL

    execute <<~SQL
      CREATE CONSTRAINT TRIGGER check_single_keyword_selection_t
      AFTER INSERT OR UPDATE ON meta_data_keywords
      DEFERRABLE INITIALLY DEFERRED
      FOR EACH ROW EXECUTE FUNCTION check_single_keyword_selection_f();
    SQL
  end

  def down
    execute <<~SQL
      DROP TRIGGER IF EXISTS check_single_keyword_selection_t ON meta_keys;
      DROP FUNCTION IF EXISTS check_single_keyword_selection_f();
    SQL
  end
end
