class AllowedPersonTypeColumnForMetaKeys < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL.strip_heredoc
      ALTER TABLE meta_keys
      ADD CONSTRAINT check_allowed_people_subtypes_not_empty_for_meta_datum_people
      CHECK (
        (allowed_people_subtypes IS NOT NULL
        AND coalesce(array_length(allowed_people_subtypes, 1), 0) > 0)
        OR meta_datum_object_type != 'MetaDatum::People'
      );
    SQL
  end

  def down
    execute <<-SQL.strip_heredoc
      ALTER TABLE people
      DROP CONSTRAINT check_allowed_people_subtypes_not_empty_for_meta_datum_people
    SQL
  end
end
