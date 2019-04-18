class CheckConstraintForPersonColumns < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      ALTER TABLE people
      ADD CONSTRAINT check_presence_of_first_name_or_last_name_or_pseudonym
      CHECK (first_name IS NOT NULL OR last_name IS NOT NULL OR pseudonym IS NOT NULL)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE people
      DROP CONSTRAINT check_presence_of_first_name_or_last_name_or_pseudonym
    SQL
  end
end
