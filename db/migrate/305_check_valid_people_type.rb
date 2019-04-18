class CheckValidPeopleType < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      ALTER TABLE people
      ADD CONSTRAINT check_valid_people_subtype
      CHECK (subtype IN ('Person', 'PeopleGroup', 'PeopleInstitutionalGroup'))
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE people
      DROP CONSTRAINT check_valid_people_subtype
    SQL
  end
end
