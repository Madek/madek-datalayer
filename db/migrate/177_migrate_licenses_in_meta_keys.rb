class MigrateLicensesInMetaKeys < ActiveRecord::Migration[4.2]
  def change
    reversible do |dir|
      dir.up do
        execute \
          %(UPDATE meta_keys \
            SET meta_datum_object_type = 'MetaDatum::Licenses' \
            WHERE meta_datum_object_type = 'MetaDatum::License')
      end
    end
  end
end
