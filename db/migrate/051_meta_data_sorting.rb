class MetaDataSorting < ActiveRecord::Migration[6.1]
  def change
    add_column(:meta_data_keywords, :position, :integer, null: false, default: 0)
    add_column(:meta_data_people, :position, :integer, null: false, default: 0)
  end
end
