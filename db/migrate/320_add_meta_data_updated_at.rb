class AddMetaDataUpdatedAt < ActiveRecord::Migration[4.2]
  def change


    %w(media_entries collections filter_sets).each do |table_name|
      reversible do |dir|
        dir.up do
          execute <<-SQL.strip_heredoc
            ALTER TABLE #{table_name} ADD COLUMN meta_data_updated_at timestamp with time zone;
            UPDATE #{table_name} SET meta_data_updated_at = edit_session_updated_at;
            ALTER TABLE #{table_name} ALTER COLUMN meta_data_updated_at SET NOT NULL;
            ALTER TABLE #{table_name} ALTER COLUMN meta_data_updated_at SET DEFAULT now();
          SQL
        end
        dir.down do
          execute <<-SQL.strip_heredoc
            ALTER TABLE #{table_name} DROP COLUMN meta_data_updated_at CASCADE;
          SQL
        end
      end
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL.strip_heredoc
          CREATE OR REPLACE FUNCTION propagate_meta_data_updates_to_media_resource()
          RETURNS TRIGGER AS $$
          DECLARE
            md_id UUID;
          BEGIN
            CASE
              WHEN TG_OP = 'DELETE' THEN
                md_id = OLD.id;
              ELSE
                md_id = NEW.id;
            END CASE;


            UPDATE media_entries SET meta_data_updated_at = now()
              FROM meta_data
              WHERE meta_data.media_entry_id = media_entries.id
              AND meta_data.id = md_id;

            UPDATE collections SET meta_data_updated_at = now()
              FROM meta_data
              WHERE meta_data.collection_id = collections.id
              AND meta_data.id = md_id;

            UPDATE filter_sets SET meta_data_updated_at = now()
              FROM meta_data
              WHERE meta_data.media_entry_id = filter_sets.id
              AND meta_data.id = md_id;


            RETURN NULL;
          END;
          $$ language 'plpgsql';

          CREATE TRIGGER propagate_meta_data_updates_to_media_resource
            AFTER INSERT OR DELETE OR UPDATE
            ON meta_data
            FOR EACH ROW EXECUTE PROCEDURE propagate_meta_data_updates_to_media_resource();
        SQL
      end
      dir.down do
        execute <<-SQL.strip_heredoc
          DROP TRIGGER propagate_meta_data_updates_to_media_resource  ON meta_data;
          DROP FUNCTION propagate_meta_data_updates_to_media_resource();
        SQL
      end
    end

  end
end
