class MetaDataCleanUp < ActiveRecord::Migration[5.2]

  def meta_data_types
    %w[
      MetaDatum::JSON
      MetaDatum::Keywords
      MetaDatum::MediaEntry
      MetaDatum::People
      MetaDatum::Roles
      MetaDatum::Text
      MetaDatum::TextDate
    ]
  end

  def up
    execute <<-SQL
      ALTER TABLE meta_data DROP CONSTRAINT check_valid_type;
      ALTER TABLE meta_data ADD CONSTRAINT check_valid_type CHECK (type IN (#{meta_data_types.uniq.map{|s|"'#{s}'"}.join(', ')}));

      ALTER TABLE meta_data ADD CONSTRAINT media_entry_type_consistent
        CHECK ((type <> 'MetaDatum::MediaEntry' AND other_media_entry_id IS NULL)
                OR (type = 'MetaDatum::MediaEntry' AND other_media_entry_id IS NOT NULL));

      DELETE FROM meta_data WHERE type = 'MetaDatum::MediaEntry'
        AND NOT EXISTS (SELECT true FROM media_entries WHERE media_entries.id = meta_data.other_media_entry_id);

      ALTER TABLE meta_data ADD CONSTRAINT other_media_entry_fkey
        FOREIGN KEY (other_media_entry_id) REFERENCES media_entries(id)
        ON DELETE CASCADE;

    SQL

    def down
      execute <<-SQL
      ALTER TABLE meta_data DROP CONSTRAINT check_valid_type;
      ALTER TABLE meta_data DROP CONSTRAINT media_entry_type_consistent;
      ALTER TABLE meta_data DROP CONSTRAINT other_media_entry_fkey;
      SQL
    end

  end
end

