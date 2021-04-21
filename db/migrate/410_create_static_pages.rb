class CreateStaticPages < ActiveRecord::Migration[5.2]
  include Madek::MigrationHelper

  def change
    create_table :static_pages, id: false do |t|
      t.primary_key :id, :uuid, default: 'gen_random_uuid()'
      t.string :name, null: false
      t.hstore :contents, null: false, default: {}
      t.index :name, unique: true
      t.timestamps null: false
    end

    reversible do |dir|
      dir.up do
        set_timestamps_defaults(:static_pages)

        execute <<-SQL.strip_heredoc
          ALTER TABLE static_pages
          ADD CONSTRAINT name_non_blank CHECK (name !~ '^\s*$')
        SQL

        execute <<-SQL.strip_heredoc
          CREATE OR REPLACE FUNCTION static_pages_check_content_for_default_locale()
          RETURNS TRIGGER AS $$
          DECLARE
            default_locale_from_app_settings varchar(5);
          BEGIN
            default_locale_from_app_settings := (SELECT default_locale FROM app_settings LIMIT 1);
            IF
              NEW.contents->(default_locale_from_app_settings) ~ '^\s*$'
              OR NEW.contents->(default_locale_from_app_settings) IS NULL
            THEN RAISE EXCEPTION 'Content for % locale cannot be blank!', upper(default_locale_from_app_settings);
            END IF;
            RETURN NEW;
          END;
          $$ LANGUAGE plpgsql;
        SQL

        execute <<-SQL.strip_heredoc
          CREATE TRIGGER check_contents_of_static_pages
          BEFORE INSERT OR UPDATE ON static_pages FOR EACH ROW
          EXECUTE PROCEDURE
          static_pages_check_content_for_default_locale();
        SQL
      end

      dir.down do
        execute 'DROP TRIGGER check_contents_of_static_pages ON static_pages'
        execute 'DROP FUNCTION static_pages_check_content_for_default_locale()'
        execute 'ALTER TABLE static_pages DROP CONSTRAINT name_non_blank'
      end
    end
  end
end
