class AddBetaTesterGroupQuickEdit < ActiveRecord::Migration
  class ::Group < ActiveRecord::Base
    self.table_name = 'groups'
  end
  class ::InstitutionalGroup < ::Group
  end

  # NOTE: InstitutionalGroup because they can't be deleted by admin!
  def change
    Group.reset_column_information

    # the id is UUIDTools::UUID.sha1_create(Madek::Constants::MADEK_UUID_NS, "beta_test_quick_edit").to_s
    id = '8ffe3710-088c-5b31-ad23-573335c9017a'

    Group.create!(
      id: id,
      name: 'Beta-Tester "Metadaten-Stapelverarbeitung"',
      institutional_id: 'beta_test_quick_edit',
      institutional_name: nil,
      type: 'InstitutionalGroup'
    )
  end
end
