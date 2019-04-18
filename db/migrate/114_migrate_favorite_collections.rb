class MigrateFavoriteCollections < ActiveRecord::Migration[4.2]
  include Madek::MediaResourceMigrationModels

  def change
    MigrationFavorite
      .joins('INNER JOIN media_resources ON favorites.media_resource_id = media_resources.id')
      .where(media_resources: { type: 'MediaSet' })
      .each do |f|
      next if MigrationFavoriteCollection.find_by(user_id: f.user_id,
                                                  collection_id: f.media_resource_id)
      MigrationFavoriteCollection.create!(user_id: f.user_id,
                                          collection_id: f.media_resource_id)
    end
  end

end
