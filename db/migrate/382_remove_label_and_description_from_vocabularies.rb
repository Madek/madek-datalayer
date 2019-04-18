class RemoveLabelAndDescriptionFromVocabularies < ActiveRecord::Migration[4.2]
  class MigrationVocabulary < ActiveRecord::Base
    self.table_name = 'vocabularies'
  end

  def change
    reversible do |dir|
      dir.up do
        remove_column :vocabularies, :label
        remove_column :vocabularies, :description
      end

      dir.down do
        add_column :vocabularies, :label, :string
        add_column :vocabularies, :description, :text

        ActiveRecord::Base.transaction do
          MigrationVocabulary.find_each do |voc|
            voc.update_columns(
              label: voc.labels[default_locale],
              description: voc.descriptions[default_locale]
            )
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
