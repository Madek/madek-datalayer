class BooleanColumnsForMetaKeys < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL.strip_heredoc
      ALTER TABLE meta_keys
      ADD CONSTRAINT check_is_extensible_list_is_boolean_for_meta_datum_keywords
      CHECK (
        ((is_extensible_list = TRUE OR is_extensible_list = FALSE)
        AND meta_datum_object_type = 'MetaDatum::Keywords')
        OR meta_datum_object_type != 'MetaDatum::Keywords'
      );
    SQL

    execute <<-SQL.strip_heredoc
      ALTER TABLE meta_keys
      ADD CONSTRAINT check_keywords_alphabetical_order_is_boolean_for_meta_datum_keywords
      CHECK (
        ((keywords_alphabetical_order = TRUE OR keywords_alphabetical_order = FALSE)
        AND meta_datum_object_type = 'MetaDatum::Keywords')
        OR meta_datum_object_type != 'MetaDatum::Keywords'
      );
    SQL
  end

  def down
    execute <<-SQL.strip_heredoc
      ALTER TABLE meta_keys
      DROP CONSTRAINT check_is_extensible_list_is_boolean_for_meta_datum_keywords
    SQL

    execute <<-SQL.strip_heredoc
      ALTER TABLE meta_keys
      DROP CONSTRAINT check_keywords_alphabetical_order_is_boolean_for_meta_datum_keywords
    SQL
  end
end
