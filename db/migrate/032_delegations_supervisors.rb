class DelegationsSupervisors < ActiveRecord::Migration[6.1]
  include Madek::MigrationHelper

  def up
    create_table(:delegations_supervisors, id: false) do |t|
      t.uuid(:delegation_id, null: false)
      t.uuid(:user_id, null: false)
    end
    add_column(:delegations_supervisors, :created_at, :datetime, null: false)
    add_auto_timestamps(:delegations_supervisors, updated_at: false)
    add_foreign_key(:delegations_supervisors, :delegations, on_delete: :cascade)
    add_foreign_key(:delegations_supervisors, :users, on_delete: :cascade)
    add_index(:delegations_supervisors, %i[delegation_id user_id], unique: true)

    execute <<-SQL.strip_heredoc
      CREATE TRIGGER delegations_supervisors_audit_change 
      AFTER INSERT OR DELETE OR UPDATE 
      ON delegations_supervisors
      FOR EACH ROW EXECUTE FUNCTION audit_change();
    SQL

    # 2nd step later in future:
    #
    # execute <<~SQL
    #   CREATE OR REPLACE FUNCTION check_delegations_supervisors_f()
    #   RETURNS TRIGGER AS $$
    #   BEGIN
    #     IF NOT EXISTS (SELECT 1 FROM delegations_supervisors WHERE delegation_id = NEW.id) THEN
    #       RAISE EXCEPTION 'No associated row in delegations_supervisors for delegation_id %', NEW.id;
    #     END IF;
    #     RETURN NEW;
    #   END;
    #   $$ LANGUAGE plpgsql;

    #   CREATE CONSTRAINT TRIGGER check_delegations_supervisors_t
    #   AFTER INSERT OR UPDATE ON delegations
    #   DEFERRABLE INITIALLY DEFERRED
    #   FOR EACH ROW EXECUTE PROCEDURE check_delegations_supervisors_f();
    # SQL

    # execute <<~SQL
    #   CREATE OR REPLACE FUNCTION check_delegations_supervisors_delete_f()
    #   RETURNS TRIGGER AS $$
    #   BEGIN
    #     IF (SELECT COUNT(*) FROM delegations_supervisors WHERE delegation_id = OLD.delegation_id) <= 1 THEN
    #       RAISE EXCEPTION 'At least one entry in delegations_supervisors for delegation_id % must exist', OLD.delegation_id;
    #     END IF;
    #     RETURN OLD;
    #   END;
    #   $$ LANGUAGE plpgsql;

    #   CREATE TRIGGER delegations_supervisors_delete_t
    #   BEFORE DELETE ON delegations_supervisors
    #   FOR EACH ROW EXECUTE PROCEDURE check_delegations_supervisors_delete_f();
    # SQL
  end

  def down
    drop_table(:delegations_supervisors)

    # 2nd step later in future:
    #
    # execute <<~SQL
    #   DROP TRIGGER IF EXISTS check_delegations_supervisors_t ON delegations;
    #   DROP FUNCTION IF EXISTS check_delegations_supervisors_f();
    # SQL

    # execute <<~SQL
    #   DROP TRIGGER IF EXISTS delegations_supervisors_delete_t ON delegations_supervisors;
    #   DROP FUNCTION IF EXISTS check_delegations_supervisors_delete_f();
    # SQL
  end
end
