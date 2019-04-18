class TimestampsWithTimeZone < ActiveRecord::Migration[4.2]
  def change

    res = execute <<-SQL.strip_heredoc
      SELECT table_name from INFORMATION_SCHEMA.views WHERE table_schema = ANY (current_schemas(false));
    SQL

    view_names = res.to_a.map(&:first).map(&:to_a).map(&:second)


    views = view_names.map do |view_name|
      res = execute <<-SQL.strip_heredoc
        SELECT pg_get_viewdef('#{view_name}', true)
      SQL
      view = res.to_a.map(&:first).to_a.map(&:second).first
      [view_name, view]
    end.to_h

    views.each do |name,view|
      execute "DROP VIEW #{name}"
    end

    tables = execute <<-SQL.strip_heredoc
      SELECT
        c.relname as "Name",
        n.nspname as "Schema",
        CASE c.relkind WHEN 'r' THEN 'table' WHEN 'v' THEN 'view' WHEN 'm' THEN 'materialized view' WHEN 'i' THEN 'index' WHEN 'S' THEN 'sequence' WHEN 's' THEN 'special' WHEN 'f' THEN 'foreign table' END as "Type",
        pg_catalog.pg_get_userbyid(c.relowner) as "Owner"
      FROM pg_catalog.pg_class c
           LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
      WHERE c.relkind IN ('r','')
            AND n.nspname <> 'pg_catalog'
            AND n.nspname <> 'information_schema'
            AND n.nspname !~ '^pg_toast'
        AND pg_catalog.pg_table_is_visible(c.oid)
      ORDER BY 1,2;
    SQL

    tables = tables.to_a.map(&:first).map(&:second)

    tables.each do |table|

      columns = execute <<-SQL.strip_heredoc
        select column_name, data_type FROM INFORMATION_SCHEMA.COLUMNS
          WHERE table_name = '#{table}'
          AND data_type ilike 'timestamp%'
       SQL

      columns.to_a.map(&:first).map(&:second).each do |column|
        puts "converting #{column} of #{table}"
        execute <<-SQL.strip_heredoc
          ALTER TABLE #{table} ALTER COLUMN #{column} SET DATA TYPE timestamp with time zone;
        SQL
      end
    end

    views.each do |name,view|
      execute <<-SQL.strip_heredoc
        CREATE VIEW #{name}
        AS #{view}
      SQL
    end

  end
end
