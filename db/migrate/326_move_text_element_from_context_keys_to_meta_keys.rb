class MoveTextElementFromContextKeysToMetaKeys < ActiveRecord::Migration[4.2]
  def change
    add_column :meta_keys, :text_type, :text, default: 'line', null: false

    execute <<-SQL
      ALTER TABLE meta_keys
        ADD CONSTRAINT check_valid_text_type
        CHECK (text_type IN ('line', 'block'));
    SQL

    MetaKey.where("vocabulary_id <> 'madek_core'") \
      .where("meta_datum_object_type = 'MetaDatum::Text'").each do |mk|
      text_elements = mk.context_keys.map(&:text_element)
      mk.update_attributes! text_type: \
        if text_elements.include? 'textarea'
          'block'
        else
          'line'
        end
    end

    execute "SET session_replication_role = REPLICA"
    MetaKey.where("vocabulary_id = 'madek_core'") \
      .where("meta_datum_object_type = 'MetaDatum::Text'").each do |mk|
        mk.update_attributes! text_type: 'line'
    end
    execute "SET session_replication_role = DEFAULT"


    execute <<-SQL
      ALTER TABLE context_keys DROP COLUMN text_element CASCADE;
      DROP TYPE text_element;

    SQL

  end
end
