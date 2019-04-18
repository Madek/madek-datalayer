class CreateMediaResourcesView < ActiveRecord::Migration[4.2]
  def up
    columns = [ :id,
                :get_metadata_and_previews,
                :responsible_user_id,
                :creator_id,
                :created_at,
                :updated_at ]

    execute <<-SQL
      CREATE OR REPLACE VIEW public.vw_media_resources AS
        (SELECT #{columns.join(', ')},
                'MediaEntry' AS type
         FROM media_entries)
        UNION
        (SELECT #{columns.join(', ')},
                'Collection' AS type
         FROM collections)
        UNION
        (SELECT #{columns.join(', ')},
                'FilterSet' AS type
         FROM filter_sets)
    SQL
  end

  def down
    execute 'DROP VIEW vw_media_resources'
  end
end
