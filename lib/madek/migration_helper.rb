module Madek
  module MigrationHelper
    extend ActiveSupport::Concern

    def create_trgm_index(t, c)
      execute "CREATE INDEX ON #{t} USING gin(#{c} gin_trgm_ops);"
    end

    def create_text_index(t, c)
      reversible do |dir|
        dir.up do
          execute "CREATE INDEX ON #{t} USING gin(to_tsvector('english',#{c}));"
        end
      end
    end

    def clean_blank_hstore_vals(klass, *columns)
      ActiveRecord::Base.transaction do
        execute "SET session_replication_role = REPLICA"

        klass.find_each do |row|
          columns.each do |column|
            row[column] = row[column].map { |loc, val| [loc, val.presence] }.to_h
          end
          row.save
        end

        execute "SET session_replication_role = DEFAULT"
      end
    end

    def add_non_blank_constraints(table_name, *columns)
      columns.each do |column_name|
        execute <<-SQL.strip_heredoc
          ALTER TABLE #{table_name}
          ADD CONSTRAINT #{column_name}_non_blank
          CHECK ('^\s*$' !~ ALL(avals(#{column_name})))
        SQL
      end
    end

    def auto_update_searchable table_name, columns
      reversible do |dir|
        dir.up do
          execute "ALTER TABLE #{table_name.to_s} DROP COLUMN IF EXISTS searchable;"
          execute "ALTER TABLE #{table_name.to_s} ADD COLUMN searchable text DEFAULT ''::text NOT NULL;"

          execute <<-SQL.strip_heredoc
            -- ALTER TABLE #{table_name} DISABLE TRIGGER update_updated_at_column_of_#{table_name};
            UPDATE #{table_name} SET searchable = ( #{columns.map{|c|  "COALESCE("+ c.to_s + "::text, '')"}.join(" || ' ' || ") } ) ;
            -- ALTER TABLE #{table_name}  ENABLE TRIGGER update_updated_at_column_of_#{table_name};
          SQL

          create_trgm_index table_name, :searchable
          create_text_index table_name, :searchable

          execute <<-SQL.strip_heredoc
            CREATE OR REPLACE FUNCTION #{table_name}_update_searchable_column()
            RETURNS TRIGGER AS $$
            BEGIN
               NEW.searchable = #{columns.map{|c| "COALESCE(NEW."+ c.to_s + "::text, '')"}.join(" || ' ' || ") } ;
               RETURN NEW;
            END;
            $$ language 'plpgsql';
          SQL

          execute <<-SQL.strip_heredoc
            CREATE TRIGGER update_searchable_column_of_#{table_name}
            BEFORE INSERT OR UPDATE ON #{table_name} FOR EACH ROW
              -- WHEN ( #{columns.map{|c| "(OLD." + c.to_s + " IS DISTINCT FROM NEW." + c.to_s + ")"}.join(" OR ")} )
            EXECUTE PROCEDURE
            #{table_name}_update_searchable_column();
          SQL


        end

        dir.down do
          execute " DROP TRIGGER  update_searchable_column_of_#{table_name} ON #{table_name} "
        end

      end
    end

    def add_auto_timestamps(table_name, created_at: true, updated_at: true)
      reversible do |dir|
        dir.up do

          if created_at
            unless column_exists? table_name, :created_at
              add_column(table_name, :created_at, 'timestamp with time zone')
            end
            # execute "UPDATE #{table_name} SET created_at = now() WHERE created_at IS NULL"
            execute "ALTER TABLE #{table_name} ALTER COLUMN created_at SET DEFAULT now()"
            # execute "ALTER TABLE #{table_name} ALTER COLUMN created_at SET NOT NULL"
          end

          if updated_at
            unless column_exists? table_name, :updated_at
              add_column(table_name, :updated_at, 'timestamp with time zone')
            end
            # execute "UPDATE #{table_name} SET updated_at = now() WHERE updated_at IS NULL"
            execute "ALTER TABLE #{table_name} ALTER COLUMN updated_at SET DEFAULT now()"
            # execute "ALTER TABLE #{table_name} ALTER COLUMN updated_at SET NOT NULL"

            execute <<-SQL.strip_heredoc
              CREATE OR REPLACE FUNCTION update_updated_at_column()
              RETURNS TRIGGER AS $$
              BEGIN
                 NEW.updated_at = now();
                 RETURN NEW;
              END;
              $$ language 'plpgsql';
            SQL

            execute <<-SQL.strip_heredoc
              CREATE TRIGGER update_updated_at_column_of_#{table_name}
              BEFORE UPDATE ON #{table_name} FOR EACH ROW
              WHEN (OLD.* IS DISTINCT FROM NEW.*)
              EXECUTE PROCEDURE
              update_updated_at_column();
            SQL
          end
        end

        dir.down do
          execute " DROP TRIGGER IF EXISTS update_updated_at_column_of_#{table_name} ON #{table_name} "
          if created_at
            remove_column(table_name, :created_at)
          end
          if updated_at
            remove_column(table_name, :updated_at)
          end
        end
      end
    end

    def set_timestamps_defaults(table_name)
      execute "ALTER TABLE #{table_name} ALTER COLUMN created_at SET DEFAULT now()"
      execute "ALTER TABLE #{table_name} ALTER COLUMN updated_at SET DEFAULT now()"
    end

  end
end
