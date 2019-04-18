class MigrateFavoriteMediaEntries < ActiveRecord::Migration[4.2]
  include Madek::MediaResourceMigrationModels

  def change
    MigrationFavorite
      .joins('INNER JOIN media_resources ON favorites.media_resource_id = media_resources.id')
      .where(media_resources: { type: 'MediaEntry' })
      .each do |f|
      next if MigrationFavoriteMediaEntry.find_by(user_id: f.user_id,
                                                  media_entry_id: f.media_resource_id)
      MigrationFavoriteMediaEntry.create!(user_id: f.user_id,
                                          media_entry_id: f.media_resource_id)
    end
  end

end
