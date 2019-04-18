class AddLocalizedLabelsToMetaKeys < ActiveRecord::Migration[4.2]
  class MigrationMetaKey < ActiveRecord::Base
    self.table_name = :meta_keys
  end

  def change
    enable_extension 'hstore'

    reversible do |dir|
      add_column :meta_keys, :labels, :hstore, default: {}, null: false

      MigrationMetaKey.reset_column_information
      dir.up do
        execute 'SET session_replication_role = replica;'
        ActiveRecord::Base.transaction do
          MigrationMetaKey.find_each do |meta_key|
            meta_key.update_column(:labels, { default_locale => meta_key.label })
          end
        end
        execute 'SET session_replication_role = DEFAULT;'
      end
    end
  end

  private

  def default_locale
    Settings.madek_default_locale
  end
end
