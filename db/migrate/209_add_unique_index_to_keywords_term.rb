class AddUniqueIndexToKeywordsTerm < ActiveRecord::Migration
  def change
    add_index :keywords, [:meta_key_id, :term], unique: true
  end
end
