class ExtendMadekCoreProtection < ActiveRecord::Migration[4.2]
  def change
  end

  def change
    reversible do |dir|
      dir.up do

        execute %{

          CREATE OR REPLACE FUNCTION check_madek_core_meta_key_immutability()
          RETURNS TRIGGER AS $$
          BEGIN
            IF (TG_OP = 'DELETE') THEN
              IF (OLD.id ilike 'madek_core:%') THEN
                RAISE EXCEPTION 'The madek_core meta_key % may not be deleted', OLD.id;
              END IF;
            ELSIF  (TG_OP = 'UPDATE') THEN
              IF (OLD.id ilike 'madek_core:%') THEN
                RAISE EXCEPTION 'The madek_core meta_key % may not be modified', OLD.id;
              END IF;
              IF (NEW.id ilike 'madek_core:%') THEN
                RAISE EXCEPTION 'The madek_core meta_key namespace may not be extended by %', NEW.id;
              END IF;
            ELSIF  (TG_OP = 'INSERT') THEN
              IF (NEW.id ilike 'madek_core:%') THEN
                RAISE EXCEPTION 'The madek_core meta_key namespace may not be extended by %', NEW.id;
              END IF;
            END IF;
            RETURN NEW;
          END;
          $$ language 'plpgsql'; }



        execute <<-SQL.strip_heredoc
          DROP TRIGGER trigger_madek_core_meta_key_immutability ON meta_keys;

          CREATE CONSTRAINT TRIGGER trigger_madek_core_meta_key_immutability
            AFTER INSERT OR UPDATE OR DELETE
            ON meta_keys
            INITIALLY DEFERRED
            FOR EACH ROW
            EXECUTE PROCEDURE check_madek_core_meta_key_immutability();
        SQL

      end
    end
  end
end
