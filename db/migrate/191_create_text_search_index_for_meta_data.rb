class CreateTextSearchIndexForMetaData < ActiveRecord::Migration[4.2]
  include Madek::MigrationHelper

  def change
    reversible do |dir|
      dir.up do
        create_trgm_index :meta_data, :string
        create_text_index :meta_data, :string
      end
    end
  end
end
