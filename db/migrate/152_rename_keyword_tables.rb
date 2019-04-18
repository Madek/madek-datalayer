class RenameKeywordTables < ActiveRecord::Migration[4.2]
  def change
    rename_table :keywords, :meta_data_keywords
    rename_table :keyword_terms, :keywords
    rename_column :meta_data_keywords, :keyword_term_id, :keyword_id
  end
end
