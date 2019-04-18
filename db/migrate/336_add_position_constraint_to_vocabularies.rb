class AddPositionConstraintToVocabularies < ActiveRecord::Migration[4.2]
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE vocabularies ALTER COLUMN position SET NOT NULL;
          ALTER TABLE vocabularies ADD CONSTRAINT positive_position CHECK (position >= 0)
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE vocabularies ALTER COLUMN position SET NULL;
          ALTER TABLE vocabularies DROP CONSTRAINT positive_position
        SQL
      end
    end
  end
end
