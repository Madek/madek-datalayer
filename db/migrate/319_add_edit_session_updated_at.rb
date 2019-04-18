class AddEditSessionUpdatedAt < ActiveRecord::Migration[4.2]
  def change
    %w(media_entries collections filter_sets).each do |table_name|
      reversible do |dir|
        dir.up do
          execute <<-SQL.strip_heredoc
            ALTER TABLE #{table_name} ADD COLUMN edit_session_updated_at timestamp with time zone;

            UPDATE #{table_name} SET edit_session_updated_at = es.ts
              FROM (SELECT max(created_at) ts,
                           edit_sessions.#{table_name.singularize}_id #{table_name.singularize}_id
                      FROM edit_sessions
                      GROUP BY edit_sessions.#{table_name.singularize}_id) es
              WHERE es.#{table_name.singularize}_id = #{table_name}.id;


            UPDATE #{table_name} SET edit_session_updated_at = updated_at
              WHERE edit_session_updated_at IS NULL;

            ALTER TABLE #{table_name} ALTER COLUMN edit_session_updated_at SET NOT NULL;
            ALTER TABLE #{table_name} ALTER COLUMN edit_session_updated_at SET DEFAULT now();

            CREATE FUNCTION propagate_edit_session_insert_to_#{table_name}()
            RETURNS TRIGGER AS $$
            BEGIN
              UPDATE #{table_name} SET edit_session_updated_at = now()
                FROM edit_sessions
                WHERE edit_sessions.id = NEW.id
                AND #{table_name}.id = edit_sessions.#{table_name.singularize}_id;
              RETURN NULL;
            END;
            $$ language 'plpgsql';

            CREATE TRIGGER propagate_edit_session_insert_to_#{table_name}
              AFTER INSERT ON edit_sessions
              FOR EACH ROW EXECUTE PROCEDURE propagate_edit_session_insert_to_#{table_name}();

          SQL
        end
        dir.down do
          execute <<-SQL.strip_heredoc
            DROP TRIGGER propagate_edit_session_insert_to_#{table_name};
            DROP FUNCTION propagate_edit_session_insert_to_#{table_name}();
            ALTER TABLE #{table_name} DROP COLUMN edit_session_updated_at CASCADE;
          SQL
        end
      end
    end

  end
end
