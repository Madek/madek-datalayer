class AddIndexExternalUrIs < ActiveRecord::Migration[6.1]
  def change
    add_index :people, :external_uris, using: 'gin'
    add_index :keywords, :external_uris, using: 'gin'
  end
end
