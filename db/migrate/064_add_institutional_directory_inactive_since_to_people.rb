class AddInstitutionalDirectoryInactiveSinceToPeople < ActiveRecord::Migration[7.2]
  def change
    add_column :people, :institutional_directory_inactive_since, 'timestamp with time zone', null: true
  end
end