class AddLocalizedDescriptionsToVocabularies < ActiveRecord::Migration
  class MigrationVocabulary < ActiveRecord::Base
    self.table_name = :vocabularies
  end

  def change
    enable_extension 'hstore'

    reversible do |dir|
      add_column :vocabularies, :descriptions, :hstore, default: {}, null: false

      MigrationVocabulary.reset_column_information
      dir.up do
        execute 'SET session_replication_role = replica;'
        ActiveRecord::Base.transaction do
          MigrationVocabulary.find_each do |vocabulary|
            vocabulary.update_column(:descriptions, { default_locale => vocabulary.description })
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
