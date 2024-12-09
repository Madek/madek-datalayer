class AddConstraintForDelegationSupervisors < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION check_delegation_supervisors_on_delegations_f()
      RETURNS TRIGGER AS $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM delegations_supervisors WHERE delegation_id = NEW.id
        ) THEN
          RAISE EXCEPTION 'A delegation must have at least one supervisor';
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;

      CREATE CONSTRAINT TRIGGER check_delegation_supervisors_on_delegations_t
      AFTER INSERT OR UPDATE ON delegations
      DEFERRABLE INITIALLY DEFERRED
      FOR EACH ROW EXECUTE FUNCTION check_delegation_supervisors_on_delegations_f();
    SQL

    execute <<-SQL
      CREATE OR REPLACE FUNCTION check_delegations_supervisors_f()
      RETURNS TRIGGER AS $$
      BEGIN
        IF EXISTS (
            SELECT 1 FROM delegations WHERE id = OLD.delegation_id
        ) AND NOT EXISTS (
            SELECT 1 FROM delegations_supervisors WHERE delegation_id = OLD.delegation_id
        ) THEN
          RAISE EXCEPTION 'A delegation must have at least one supervisor';
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;

      CREATE CONSTRAINT TRIGGER check_delegations_supervisors_t
      AFTER DELETE ON delegations_supervisors
      DEFERRABLE INITIALLY DEFERRED
      FOR EACH ROW EXECUTE FUNCTION check_delegations_supervisors_f();
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS check_delegation_supervisors_on_delegations_t ON delegations;
      DROP FUNCTION IF EXISTS check_delegation_supervisors_on_delegations_f();
    SQL

    execute <<-SQL
      DROP TRIGGER IF EXISTS check_delegations_supervisors_t ON delegations_supervisors;
      DROP FUNCTION IF EXISTS check_delegations_supervisors_f();
    SQL
  end
end
