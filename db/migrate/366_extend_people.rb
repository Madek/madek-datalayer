class ExtendPeople < ActiveRecord::Migration

  def up
    execute <<-SQL

      ALTER TABLE people
        ADD COLUMN description text,
        ADD COLUMN external_uri character varying;

    SQL
  end
end
