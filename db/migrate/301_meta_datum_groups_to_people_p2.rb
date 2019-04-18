class MetaDatumGroupsToPeopleP2 < ActiveRecord::Migration[4.2]
  include Madek::MigrationHelper

  def change
    drop_table :meta_data_groups

    ### is_bunch => subtype ######################################################
    add_column :people, :subtype, :text
    execute <<-SQL
      UPDATE people SET subtype = 'PeopleGroup' WHERE is_bunch = true AND institutional_id IS NULL;
      UPDATE people SET subtype = 'PeopleInstitutionalGroup' WHERE is_bunch = true AND institutional_id IS NOT NULL;
      UPDATE people SET subtype = 'Person' WHERE subtype IS NULL;
    SQL
    remove_column :people, :is_bunch
    change_column :people, :subtype, :text, null: false
  end

end
