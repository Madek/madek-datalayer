class AddBetaTesterGroupQuickEdit < ActiveRecord::Migration[4.2]
  class ::MigrationQuickEditGroup < ActiveRecord::Base
    self.table_name = 'groups'
    self.inheritance_column = :_not_existing_column
  end

  # NOTE: InstitutionalGroup because they can't be deleted by admin!
  def change
    MigrationQuickEditGroup.reset_column_information

    # the id is UUIDTools::UUID.sha1_create(Madek::Constants::MADEK_UUID_NS, "beta_test_quick_edit").to_s
    id = '8ffe3710-088c-5b31-ad23-573335c9017a'

    MigrationQuickEditGroup.create!(
      id: id,
      name: 'Beta-Tester "Metadaten-Stapelverarbeitung"',
      institutional_id: 'beta_test_quick_edit',
      institutional_name: nil,
      type: 'InstitutionalGroup'
    )
  end
end
