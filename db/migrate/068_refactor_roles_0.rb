class RefactorRoles0 < ActiveRecord::Migration[7.2]
  include Madek::MigrationHelper

  class MigrationMetaDatumRole < ActiveRecord::Base
    self.table_name = 'meta_data_roles'

    def self.duplicates_base
      select(:meta_datum_id,
             Arel.sql("array_agg(DISTINCT person_id) AS person_ids"),
             Arel.sql("array_agg(DISTINCT role_id) AS role_ids"))
        .group(:meta_datum_id, :person_id, :role_id)
        .having(Arel.sql("count(*) > 1"))
    end
  end

  def up
    with_roles = MigrationMetaDatumRole
      .duplicates_base
      .where.not(role_id: nil)

    without_roles = MigrationMetaDatumRole
      .duplicates_base
      .where(role_id: nil)

     [with_roles, without_roles].each do |wr|
       wr.each do |mdr|
         keep_row, *rest_rows =  MigrationMetaDatumRole.where(
           meta_datum_id: mdr.meta_datum_id,
           person_id: mdr.person_ids.first,
           role_id: mdr.role_ids.first
         ).order(:position)

         rest_rows.each(&:destroy!)
       end
     end
  end
end
