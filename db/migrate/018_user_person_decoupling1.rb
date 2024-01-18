class UserPersonDecoupling1 < ActiveRecord::Migration[6.1]

  def up
    add_column :users, :last_name, :text
    add_column :users, :first_name, :text


    execute <<-SQL.strip_heredoc
      CREATE OR REPLACE FUNCTION public.users_update_searchable_column() RETURNS trigger
        LANGUAGE plpgsql
        AS $$
      BEGIN
        NEW.searchable = COALESCE(NEW.last_name::text, '') || ' ' || COALESCE(NEW.first_name::text, '') || ' ' || COALESCE(NEW.login::text, '') || ' ' || COALESCE(NEW.email::text, '') ;
        RETURN NEW;
      END;
      $$;
    SQL


    execute <<-SQL.strip_heredoc

      -- DROP TRIGGER

      DROP TRIGGER update_updated_at_column_of_users ON users;

      UPDATE users
      SET last_name = people.last_name, first_name = people.first_name
      FROM people
      WHERE people.id = users.person_id;

      CREATE TRIGGER update_updated_at_column_of_users BEFORE UPDATE ON public.users FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE FUNCTION public.update_updated_at_column();


    SQL

  end

end

