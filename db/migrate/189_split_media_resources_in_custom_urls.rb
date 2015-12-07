class SplitMediaResourcesInCustomUrls < ActiveRecord::Migration
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

    add_index :custom_urls, [:media_entry_id, :is_primary], unique: true
    add_index :custom_urls, [:collection_id, :is_primary], unique: true
    add_index :custom_urls, [:filter_set_id, :is_primary], unique: true

    remove_column :custom_urls, :media_resource_id
  end
end
