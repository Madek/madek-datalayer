class RemoveLabelDescriptionAndHintFromContextKeys < ActiveRecord::Migration[4.2]
  include Madek::MigrationHelper

  class MigrationContextKey < ActiveRecord::Base
    self.table_name = 'context_keys'
  end

  def change
    remove_column :context_keys, :label
    remove_column :context_keys, :description
    remove_column :context_keys, :hint

    clean_blank_hstore_vals(MigrationContextKey, :labels, :descriptions, :hints)
    add_non_blank_constraints(MigrationContextKey.table_name, :labels, :descriptions, :hints)
  end

  private

  def default_locale
    Settings.madek_default_locale
  end
end
