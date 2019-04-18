class SplitMediaResourcesInCustomUrls < ActiveRecord::Migration[4.2]
  def up
    add_column :custom_urls, :media_entry_id, :uuid
    add_column :custom_urls, :collection_id, :uuid
    add_column :custom_urls, :filter_set_id, :uuid

    execute \
      "UPDATE custom_urls " \
      "SET media_entry_id = media_resource_id " \
      "FROM media_resources " \
      "WHERE media_resources.id = custom_urls.media_resource_id " \
        "AND media_resources.type = 'MediaEntry'"

    execute \
      "UPDATE custom_urls " \
      "SET collection_id = media_resource_id " \
      "FROM media_resources " \
      "WHERE media_resources.id = custom_urls.media_resource_id " \
        "AND media_resources.type = 'MediaSet'"

    execute \
      "UPDATE custom_urls " \
      "SET filter_set_id = media_resource_id " \
      "FROM media_resources " \
      "WHERE media_resources.id = custom_urls.media_resource_id " \
        "AND media_resources.type = 'FilterSet'"

    execute %{ ALTER TABLE custom_urls ADD CONSTRAINT custom_url_is_related CHECK
               (   (media_entry_id IS     NULL AND collection_id IS     NULL AND filter_set_id IS NOT NULL)
                OR (media_entry_id IS     NULL AND collection_id IS NOT NULL AND filter_set_id IS     NULL)
                OR (media_entry_id IS NOT NULL AND collection_id IS     NULL AND filter_set_id IS     NULL))
             }

    add_foreign_key :custom_urls, :media_entries
    add_foreign_key :custom_urls, :collections
    add_foreign_key :custom_urls, :filter_sets

    %w(media_entry collection filter_set).each do |media_resource|
      execute <<-SQL
        CREATE OR REPLACE FUNCTION check_#{media_resource}_primary_uniqueness()
        RETURNS TRIGGER AS $$
        BEGIN
          IF
            (SELECT
              (SELECT COUNT(1)
               FROM custom_urls
               WHERE custom_urls.is_primary IS true
               AND custom_urls.#{media_resource}_id = NEW.#{media_resource}_id)
            > 1)
            THEN RAISE EXCEPTION 'There exists already a primary id for #{media_resource} %.', NEW.#{media_resource}_id;
          END IF;
          RETURN NEW;
        END;
        $$ language 'plpgsql';
      SQL

      execute <<-SQL
        CREATE CONSTRAINT TRIGGER trigger_check_#{media_resource}_primary_uniqueness
        AFTER INSERT OR UPDATE
        ON custom_urls
        INITIALLY DEFERRED
        FOR EACH ROW
        EXECUTE PROCEDURE check_#{media_resource}_primary_uniqueness()
      SQL
    end

    remove_column :custom_urls, :media_resource_id
  end
end
