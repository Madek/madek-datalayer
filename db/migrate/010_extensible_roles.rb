class ExtensibleRoles < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL
      ALTER TABLE meta_keys
      DROP CONSTRAINT IF EXISTS check_is_extensible_list_is_boolean_for_meta_datum_keywords
    SQL

    execute <<~SQL
      ALTER TABLE meta_keys
      ADD CONSTRAINT check_is_extensible_list_is_boolean_for_respective_meta_datum_types
      CHECK (
        (is_extensible_list = true OR is_extensible_list = false)
          AND meta_datum_object_type IN ('MetaDatum::Keywords'::text, 'MetaDatum::Roles'::text)
        OR meta_datum_object_type NOT IN ('MetaDatum::Keywords'::text, 'MetaDatum::Roles'::text)
      )
    SQL
  end

  def down
    execute <<~SQL
      ALTER TABLE meta_keys
      DROP CONSTRAINT IF EXISTS check_is_extensible_list_is_boolean_for_respective_meta_datum_types
    SQL

    execute <<~SQL
      ALTER TABLE meta_keys
      ADD CONSTRAINT check_is_extensible_list_is_boolean_for_meta_datum_keywords
      CHECK (
        (is_extensible_list = true OR is_extensible_list = false)
          AND meta_datum_object_type = 'MetaDatum::Keywords'::text
        OR meta_datum_object_type <> 'MetaDatum::Keywords'::text
      )
    SQL
  end
end
