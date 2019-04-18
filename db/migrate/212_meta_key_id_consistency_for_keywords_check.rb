class MetaKeyIdConsistencyForKeywordsCheck < ActiveRecord::Migration[4.2]
  def change

    reversible do |dir|
      dir.up do

        execute %{

          CREATE OR REPLACE FUNCTION check_meta_key_id_consistency_for_keywords()
          RETURNS TRIGGER AS $$
          BEGIN

            IF (SELECT meta_key_id
                FROM meta_data
                WHERE meta_data.id = NEW.meta_datum_id) <>
               (SELECT meta_key_id
                FROM keywords
                WHERE id = NEW.keyword_id)
            THEN
                RAISE EXCEPTION 'The meta_key_id for meta_data and keywords must be identical';
            END IF;

            RETURN NEW;
          END;
          $$ language 'plpgsql'; }

        execute %[
          CREATE CONSTRAINT TRIGGER trigger_meta_key_id_for_keyword_consistency
          AFTER INSERT OR UPDATE
          ON meta_data_keywords
          INITIALLY DEFERRED
          FOR EACH ROW
          EXECUTE PROCEDURE check_meta_key_id_consistency_for_keywords()
        ]
      end

      dir.down do
        execute %( DROP TRIGGER trigger_meta_key_id_for_keyword_consistency ON meta_data_keywords )
        execute %{ DROP FUNCTION IF EXISTS check_meta_key_id_consistency_for_keywords() }
      end
    end

  end
end
