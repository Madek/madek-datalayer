class AddCatalogCachingBool < ActiveRecord::Migration[7.2]
  def up
    add_column :app_settings, :catalog_caching, :boolean, default: false, null: false
  end
end
