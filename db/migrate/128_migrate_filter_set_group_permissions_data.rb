class MigrateFilterSetGroupPermissionsData < ActiveRecord::Migration[4.2]

  include Madek::MigrationHelper
  include Madek::MediaResourceMigrationModels

  class ::MigrationFilterSetGroupPermission < ActiveRecord::Base
    self.table_name = :filter_set_group_permissions
  end

  class ::MigrationGroupPermission < ActiveRecord::Base
    self.table_name = :grouppermissions
  end

  GROUPPERMISSION_KEYS_MAP = {
    'view' => 'get_metadata_and_previews'
  }

  def change
    reversible do |dir|
      dir.up do

        set_timestamps_defaults :filter_set_group_permissions

        ::MigrationGroupPermission \
          .joins('JOIN filter_sets ON filter_sets.id = grouppermissions.media_resource_id')\
          .find_each do |gp|
            unless ::MigrationFilterSetGroupPermission.find_by(filter_set_id: gp.media_resource_id, group_id: gp.group_id)
              attributes = gp.attributes \
                .map { |k, v| k == 'media_resource_id' ? ['filter_set_id', v] : [k, v] } \
                .reject { |k, v| %w(edit download manage).include? k } \
                .map { |k, v| [(GROUPPERMISSION_KEYS_MAP[k] || k), v] } \
                .instance_eval { Hash[self] }
              ::MigrationFilterSetGroupPermission.create! attributes
            end
        end
      end
    end
  end

end
