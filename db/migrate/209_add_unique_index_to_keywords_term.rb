class AddUniqueIndexToKeywordsTerm < ActiveRecord::Migration[4.2]
  def change
    add_index :keywords, [:meta_key_id, :term], unique: true
  end
end
