class Audits < ActiveRecord::Migration[6.0]
  def up

    dir = Pathname.new(__FILE__).dirname
    execute IO.read(dir.join("007_audits.sql"))

    res = execute <<-SQL.strip_heredoc 
      SELECT table_name, table_type FROM information_schema.tables 
      WHERE table_schema = 'public'
      AND table_type = 'BASE TABLE'
      ORDER BY 1 ;
    SQL

    res.map{|e| e["table_name"]}.to_set \
      .subtract(["schema_migrations", "ar_internal_metadata"]) \
      .reject{|t| /^audit.*/ =~ t}.each do |table|

        execute <<-SQL.strip_heredoc
          CREATE TRIGGER #{table}_audit_change 
            AFTER INSERT OR DELETE OR UPDATE 
            ON public.#{table} FOR EACH ROW EXECUTE FUNCTION public.audit_change();
        SQL

      end

  end
end
