class UniqueLicensesUrl < ActiveRecord::Migration[4.2]
  include Madek::MigrationHelper

  class License < ActiveRecord::Base
  end

  class MetaDataLicenses < ActiveRecord::Base
    self.table_name = 'meta_data_licenses'
  end

  def up
    ActiveRecord::Base.transaction do
      execute "SET session_replication_role = REPLICA"

      License.all.group_by(&:url).each do |licenses_bundle|
        next if licenses_bundle.first.nil? # skip if no url

        licenses_to_delete = licenses_bundle.second
        license_to_keep = licenses_to_delete.delete_at(0)

        licenses_to_delete.each do |license_to_delete|

          MetaDataLicenses.all.map(&:meta_datum_id).uniq do |meta_datum_id|

            if MetaDataLicenses.find_by(meta_datum_id: meta_datum_id, license_id: license_to_keep.id)
              MetaDataLicenses
                .where(meta_datum_id: meta_datum_id, license_id: license_to_delete.id)
                .delete_all
            elsif
              MetaDataLicenses
                .where(meta_datum_id: meta_datum_id, license_id: license_to_delete.id)
                .update_all(license_id: license_to_keep.id)
            end

          end

          execute \
            "DELETE FROM licenses WHERE id = '#{license_to_delete.id}'"
        end
      end

      execute "SET session_replication_role = DEFAULT"
    end

    add_index :licenses, :url, unique: true
  end
end
