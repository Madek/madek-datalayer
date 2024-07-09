class UpcaseMethodInAuditedRequests < ActiveRecord::Migration[6.1]

  def up
    execute <<~SQL
      UPDATE audited_requests
      SET method = UPPER(method)
    SQL

    execute <<~SQL
      CREATE OR REPLACE FUNCTION upcase_method_in_audited_requests_f()
      RETURNS TRIGGER AS $$
      BEGIN
        NEW.method = UPPER(NEW.method);
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL

    execute <<~SQL
      CREATE TRIGGER upcase_method_in_audited_requests_t
      BEFORE INSERT OR UPDATE ON audited_requests
      FOR EACH ROW
      EXECUTE FUNCTION upcase_method_in_audited_requests_f();
    SQL
  end

  def down
    execute <<~SQL
      DROP TRIGGER IF EXISTS upcase_method_in_audited_requests_t ON audited_requests;
      DROP FUNCTION IF EXISTS upcase_method_in_audited_requests_f();
    SQL
  end

end
