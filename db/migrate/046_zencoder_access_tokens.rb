class ZencoderAccessTokens < ActiveRecord::Migration[7.2]
  def change
    add_column(:zencoder_jobs, :access_token, :string, default: -> { "uuid_generate_v4()" })
    add_column(:zencoder_jobs, :access_token_valid_until, "timestamp with time zone",
               default: -> { "now() + interval '48 hours'" })

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE zencoder_jobs
          SET access_token = media_files.access_hash
          FROM media_files
          WHERE zencoder_jobs.media_file_id = media_files.id
            AND media_files.media_type IN ('audio', 'video')
        SQL

        execute <<-SQL
          UPDATE zencoder_jobs
          SET access_token_valid_until = now()
          WHERE state IN ('finished', 'failed') 
             OR created_at < now() - interval '48 hours' 
        SQL

        execute <<-SQL
          CREATE OR REPLACE FUNCTION update_access_token_valid_until_f()
          RETURNS TRIGGER AS $$
          BEGIN
            IF NEW.state = 'finished' OR NEW.state = 'failed' THEN
              NEW.access_token_valid_until = NOW();
            END IF;
            RETURN NEW;
          END;
          $$ LANGUAGE plpgsql;

          CREATE TRIGGER update_access_token_valid_until_t
          BEFORE INSERT OR UPDATE ON zencoder_jobs
          FOR EACH ROW
          EXECUTE FUNCTION update_access_token_valid_until_f();
        SQL
      end
    end

    change_column_null(:zencoder_jobs, :access_token, false)
    change_column_null(:zencoder_jobs, :access_token_valid_until, false)

    remove_column(:media_files, :access_hash)
  end
end
