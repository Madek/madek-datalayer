class AddLocalizedDescriptionsToContextKeys < ActiveRecord::Migration
  class MigrationContextKey < ActiveRecord::Base
    self.table_name = :context_keys
  end

  def change
    enable_extension 'hstore'

    reversible do |dir|
      add_column :context_keys, :descriptions, :hstore, default: {}, null: false

      MigrationContextKey.reset_column_information
      dir.up do
        ActiveRecord::Base.transaction do
          MigrationContextKey.find_each do |context_key|
            context_key.update_column(:descriptions, { default_locale => context_key.description })
          end
        end
      end
    end
  end

  private

  def default_locale
    Settings.madek_default_locale
  end
end
