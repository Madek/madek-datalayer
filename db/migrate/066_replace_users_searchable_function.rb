class ReplaceUsersSearchableFunction < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION users_update_searchable_column() RETURNS trigger
      LANGUAGE plpgsql
      AS $$
        BEGIN
           NEW.searchable = concat_ws(' ', NEW.id::text, NEW.first_name, NEW.last_name, NEW.login, NEW.email);
           RETURN NEW;
        END;
      $$;
    SQL

    execute <<-SQL
      UPDATE users SET id = id
    SQL
  end
end
