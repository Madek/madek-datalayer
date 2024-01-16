class DropGroupsPersonId < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL
      ALTER TABLE groups DROP COLUMN person_id;
    SQL
  end

  def down
    execute <<~SQL
      ALTER TABLE groups ADD COLUMN person_id uuid;
    SQL
  end
end
