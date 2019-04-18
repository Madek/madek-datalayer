class AddExplorePageFieldsToAppSettings < ActiveRecord::Migration[4.2]
  def change
    add_column :app_settings, :catalog_title, :string, default: 'Catalog', null: false
    add_column :app_settings, :catalog_subtitle, :string, default: 'Browse the catalog', null: false
    add_column :app_settings, :catalog_context_keys, :string, array: true, default: [], null: false
    add_column :app_settings, :featured_set_title, :string, default: 'Featured Content'
    add_column :app_settings, :featured_set_subtitle, :string, default: 'Highlights from this Archive'
    remove_column :app_settings, :catalog_set_id, :string
  end
end
