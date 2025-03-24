class AddInstitutionalDirectoryInfosToPeople < ActiveRecord::Migration[7.2]
  def change
    add_column :people, :institutional_directory_infos, :string, array: true, null: false, default: []
  end
end