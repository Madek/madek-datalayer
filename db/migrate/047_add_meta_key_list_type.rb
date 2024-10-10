class AddMetaKeyListType < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL
      ALTER TABLE meta_keys ADD COLUMN multiple_selection boolean DEFAULT true NOT NULL;
      ALTER TABLE meta_keys ADD COLUMN selection_field_type character varying DEFAULT 'auto'::character varying NOT NULL;
    SQL

    execute <<~SQL
      ALTER TABLE meta_keys
      ADD CONSTRAINT check_selection_field_type_value
      CHECK ( selection_field_type IN ('auto', 'mark', 'list') );
    SQL

    execute <<~SQL
      CREATE OR REPLACE FUNCTION check_meta_key_multiple_selection_immutability_f()
      RETURNS TRIGGER AS $$
      BEGIN
        IF (
          OLD.multiple_selection = true AND NEW.multiple_selection = false
          AND OLD.meta_datum_object_type = 'MetaDatum::Keywords'
          AND EXISTS (
            SELECT 1
            FROM meta_data
            INNER JOIN meta_data_keywords mdk on mdk.meta_datum_id = meta_data.id
            WHERE meta_key_id = OLD.id
            GROUP BY media_entry_id, collection_id
            HAVING COUNT(*) >= 2
          )
        ) THEN
          RAISE EXCEPTION 'Cannot set multiple_selection to false when media resources with multiple keywords are present';
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL

    execute <<~SQL
      CREATE TRIGGER check_meta_key_multiple_selection_immutability_t
      BEFORE UPDATE ON meta_keys
      FOR EACH ROW EXECUTE FUNCTION check_meta_key_multiple_selection_immutability_f();
    SQL
  end

  def down
    execute <<~SQL
      DROP TRIGGER IF EXISTS check_meta_key_multiple_selection_immutability_t ON meta_keys;
      DROP FUNCTION IF EXISTS check_meta_key_multiple_selection_immutability_f();
    SQL

    execute <<~SQL
      ALTER TABLE meta_keys DROP CONSTRAINT check_selection_field_type_value;
    SQL

    execute <<~SQL
      ALTER TABLE meta_keys DROP COLUMN multiple_selection;
      ALTER TABLE meta_keys DROP COLUMN selection_field_type;
    SQL
  end
end
