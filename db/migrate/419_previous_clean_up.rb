class PreviousCleanUp < ActiveRecord::Migration[5.2]

  def previous_table table
    "previous_#{table.singularize}_ids"
  end

  def constraint table
    "#{previous_table table}_#{table.singularize}_id_fkey"
  end

  def up
    ["groups", "keywords", "people"].each do |table|

      execute <<-SQL

        DELETE FROM #{previous_table table}
          WHERE NOT EXISTS
            (SELECT true FROM #{table}
              WHERE #{table}.id = #{previous_table table}.#{table.singularize}_id);

        ALTER TABLE #{previous_table table} ADD CONSTRAINT #{constraint table}
          FOREIGN KEY (#{table.singularize}_id) REFERENCES #{table}(id)
          ON DELETE CASCADE;

      SQL
    end
  end

  def down
    ["groups", "keywords", "people"].each do |table|
      execute <<-SQL
        ALTER TABLE #{previous_table table} DROP CONSTRAINT #{constraint table};
      SQL
    end
  end

end
