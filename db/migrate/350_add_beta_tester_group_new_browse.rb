class AddBetaTesterGroupNewBrowse < ActiveRecord::Migration[4.2]
  class ::Group < ActiveRecord::Base
    self.table_name = 'groups'
  end
  class ::InstitutionalGroup < ::Group
  end

  def change
    Group.reset_column_information

    # the id is UUIDTools::UUID.sha1_create(Madek::Constants::MADEK_UUID_NS, "beta_test_new_browse").to_s
    id = '1b7416e5-daff-5e4b-b97b-021bef493c03'
    g = Group.find_or_create_by!(id: id)
    g.update_attributes(
      name: 'Beta-Tester "Neues Stöbern"',
      institutional_group_id: 'beta_test_new_browse',
      institutional_group_name: nil,
      type: 'InstitutionalGroup'
    )
  end
end
