class AddBetaTesterGroupWorkflows < ActiveRecord::Migration[5.2]
  class MigrationGroup < ActiveRecord::Base
    self.table_name = 'groups'
    self.inheritance_column = '_not_relevant_'
  end

  def change
    # the id is UUIDTools::UUID.sha1_create(Madek::Constants::MADEK_UUID_NS, "beta_test_workflows").to_s
    id = 'e12e1bc0-b29f-5e93-85d6-ff0aae9a9db0'

    MigrationGroup.create!(
      id: id,
      name: 'Beta-Tester "Workflows"',
      institutional_id: 'beta_test_workflows',
      institutional_name: nil,
      type: 'InstitutionalGroup'
    )
  end
end
