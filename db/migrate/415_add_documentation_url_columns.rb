class AddDocumentationUrlColumns < ActiveRecord::Migration[5.2]
  def change
    add_column :meta_keys, :documentation_urls, :hstore, default: {}, null: false
    add_column :context_keys, :documentation_urls, :hstore, default: {}, null: false
  end
end
