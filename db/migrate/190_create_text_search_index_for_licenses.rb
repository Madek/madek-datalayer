class CreateTextSearchIndexForLicenses < ActiveRecord::Migration
  include Madek::MigrationHelper

  def change
    reversible do |dir|
      dir.up do
        create_trgm_index :licenses, :label
        create_text_index :licenses, :label
      end
    end
  end
end
