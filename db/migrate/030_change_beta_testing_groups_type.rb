class ChangeBetaTestingGroupsType < ActiveRecord::Migration[6.1] 
  class MigrationGroup < ActiveRecord::Base
    self.table_name = 'groups'
    self.inheritance_column = nil
  end

  def up
    [Madek::Constants::BETA_TESTERS_QUICK_EDIT_GROUP_ID,
     Madek::Constants::BETA_TESTERS_WORKFLOWS_GROUP_ID].each do |gid|
      if g = MigrationGroup.find_by_id(gid)
        g.update!(type: 'Group',
                  institutional_id: nil,
                  institutional_name: nil,
                  institution: 'local')
      end
    end
  end
end
