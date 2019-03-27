class AddLocalizedDescriptionsToContexts < ActiveRecord::Migration
  class MigrationContext < ActiveRecord::Base
    self.table_name = :contexts
  end

  def change
    enable_extension 'hstore'

    reversible do |dir|
      add_column :contexts, :descriptions, :hstore, default: {}, null: false

      MigrationContext.reset_column_information
      dir.up do
        execute 'SET session_replication_role = replica;'
        ActiveRecord::Base.transaction do
          MigrationContext.find_each do |context|
            context.update_column(:descriptions, { default_locale => context.description })
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
