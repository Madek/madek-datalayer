class MetaDatumUpdatedAtOnKeywords < ActiveRecord::Migration[4.2]
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL.strip_heredoc
          ALTER TABLE meta_data_keywords ADD COLUMN meta_data_updated_at timestamp with time zone DEFAULT now() NOT NULL;
        SQL
        execute <<-SQL.strip_heredoc
          CREATE OR REPLACE FUNCTION propagate_meta_data_keyword_updates_to_meta_data()
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

          CREATE TRIGGER propagate_meta_data_keyword_updates_to_meta_data
            AFTER INSERT OR DELETE OR UPDATE
            ON meta_data_keywords
            FOR EACH ROW EXECUTE PROCEDURE propagate_meta_data_keyword_updates_to_meta_data();
        SQL

        execute <<-SQL.strip_heredoc
          CREATE OR REPLACE FUNCTION propagate_keyword_updates_to_meta_data_keywords()
          RETURNS TRIGGER AS $$
          BEGIN
            UPDATE meta_data_keywords
              SET meta_data_updated_at = now()
              WHERE keyword_id = NEW.id;
            RETURN NULL;
          END;
          $$ language 'plpgsql';

          CREATE TRIGGER propagate_keyword_updates_to_meta_data_keywords
            AFTER INSERT OR UPDATE
            ON keywords
            FOR EACH ROW EXECUTE PROCEDURE propagate_keyword_updates_to_meta_data_keywords();
        SQL

      end
      dir.down do
        execute <<-SQL.strip_heredoc
          DROP TRIGGER propagate_keyword_updates_to_meta_data_keywords;
          DROP FUNCTION propagate_keyword_updates_to_meta_data_keywords();
          DROP TRIGGER propagate_meta_data_keyword_updates_to_meta_data ON meta_data_keywords;
          DROP FUNCTION propagate_meta_data_keyword_updates_to_meta_data();
          ALTER TABLE meta_data_keywords DROP COLUMN meta_data_updated_at CASCADE;
        SQL
      end
    end

  end
end
