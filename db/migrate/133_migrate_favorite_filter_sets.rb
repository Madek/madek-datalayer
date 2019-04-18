class MigrateFavoriteFilterSets < ActiveRecord::Migration[4.2]
  include Madek::MediaResourceMigrationModels

  def change
    MigrationFavorite
      .joins('INNER JOIN media_resources ON favorites.media_resource_id = media_resources.id')
      .where(media_resources: { type: 'FilterSet' })
      .each do |f|
      next if MigrationFavoriteFilterSet.find_by(user_id: f.user_id,
                                                 filter_set_id: f.media_resource_id)
      MigrationFavoriteFilterSet.create!(user_id: f.user_id,
                                         filter_set_id: f.media_resource_id)
    end
  end

end
