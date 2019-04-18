class CleanupLicensesAndLicenseGroups < ActiveRecord::Migration[4.2]

  # remove licenses and related tables that were migrated/are not used anymore 

  def up
    execute <<-SQL
      DROP TABLE meta_data_licenses;
      DROP TABLE licenses_license_groups;
      DROP TABLE license_groups;
      DROP TABLE licenses;
    SQL
  end
end
