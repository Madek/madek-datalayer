class AddConstraintsForVocabulary < ActiveRecord::Migration[4.2]
  def change
    add_foreign_key :meta_keys, :vocabularies, on_delete: :cascade
    add_foreign_key :keywords, :meta_keys, on_delete: :cascade
  end
end
