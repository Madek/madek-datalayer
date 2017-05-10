class AddApiTokens < ActiveRecord::Migration
  include Madek::MigrationHelper


  def change

    create_table :api_tokens, id: :uuid do |t|
      t.uuid :user_id, null: false
      t.boolean :revoked, default: false, null: false
      t.boolean :scope_read, default: true, null: false
      t.boolean :scope_write, default: false, null: false
      t.text :description
    end

    add_auto_timestamps :api_tokens

    add_foreign_key :api_tokens, :users , on_delete: :cascade, on_update: :cascade

    reversible do |dir|
      dir.up do
        execute <<-SQL.strip_heredoc

          CREATE FUNCTION hash_api_token_id() RETURNS trigger
          LANGUAGE plpgsql
          AS $$
          BEGIN
            -- do not hash v5 uuids; we assume they are already hashed
            IF NEW.id::TEXT !~ '[a-f0-9]{8}-[a-f0-9]{4}-5[a-f0-9]{3}-[a-f0-9]{4}-[a-f0-9]{12}' THEN
              NEW.id = uuid_generate_v5(uuid_nil(), NEW.id::TEXT);
            END IF;
            RETURN NEW;
          END; $$;


          CREATE TRIGGER hash_api_token_id
          BEFORE INSERT ON api_tokens
          FOR EACH ROW
          EXECUTE PROCEDURE hash_api_token_id();

          -- example:

          -- INSERT INTO api_tokens (id, user_id) VALUES ('00000000-0000-0000-0000-000000000000', '08ba1f4f-0522-4a77-b087-4f3d1dd94532');

          -- INSERT INTO api_tokens (id, user_id) VALUES ('00000000-0000-5000-0000-000000000000', '08ba1f4f-0522-4a77-b087-4f3d1dd94532');

        SQL
      end
      dir.down do
         execute <<-SQL.strip_heredoc
           DROP TRIGGER hash_api_token_id ON api_tokens;
           DROP FUNCTION hash_api_token_id();
          SQL
      end
    end
  end
end
