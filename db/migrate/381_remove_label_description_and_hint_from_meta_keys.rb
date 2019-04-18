class RemoveLabelDescriptionAndHintFromMetaKeys < ActiveRecord::Migration[4.2]
  include Madek::MigrationHelper

  class MigrationMetaKey < ActiveRecord::Base
    self.table_name = 'meta_keys'
  end

  def change
    remove_column :meta_keys, :label
    remove_column :meta_keys, :description
    remove_column :meta_keys, :hint

    clean_blank_hstore_vals(MigrationMetaKey, :labels, :descriptions, :hints)
    add_non_blank_constraints(MigrationMetaKey.table_name, :labels, :descriptions, :hints)
  end

  private

  def default_locale
    Settings.madek_default_locale
  end
end
