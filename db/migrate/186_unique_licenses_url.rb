class UniqueLicensesUrl < ActiveRecord::Migration
  include Madek::MigrationHelper

  class License < ActiveRecord::Base
  end

  def up
    ActiveRecord::Base.transaction do
      execute "SET session_replication_role = REPLICA"

      ::License.all.group_by(&:url).each do |licenses_bundle|
        licenses = licenses_bundle.second
        license_to_keep = licenses.delete_at(0)

        licenses.each do |license|
          execute \
            "UPDATE meta_data_licenses " \
            "SET license_id = '#{license_to_keep.id}' " \
            "WHERE license_id = '#{license.id}'"

          execute \
            "DELETE FROM licenses WHERE id = '#{license.id}'"
        end
      end

      execute "SET session_replication_role = DEFAULT"
    end

    add_index :licenses, :url, unique: true
  end
end
