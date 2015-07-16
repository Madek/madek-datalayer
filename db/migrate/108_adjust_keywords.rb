class AdjustKeywords < ActiveRecord::Migration

  def change
    execute "DELETE FROM keywords WHERE meta_datum_id IS NULL OR keyword_term_id IS NULL;"

    rename_table :keywords, :meta_data_keywords
    rename_table :keyword_terms, :keywords

    rename_column :meta_data_keywords, :keyword_term_id, :keyword_id
    change_column :meta_data_keywords, :keyword_id, :uuid, null: false
    change_column :meta_data_keywords, :meta_datum_id, :uuid, null: false
  end

end
