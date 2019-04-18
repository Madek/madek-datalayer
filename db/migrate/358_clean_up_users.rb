class CleanUpUsers < ActiveRecord::Migration[4.2]
  include Madek::MigrationHelper

  def up

    remove_column :users, :trgm_searchable
    remove_column :users, :previous_id
    rename_column :users, :zhdkid, :institutional_id
    change_column :users, :institutional_id, :text

  end

end
