class RemoveLabelAndDescriptionFromContexts < ActiveRecord::Migration
  class MigrationContext < ActiveRecord::Base
    self.table_name = 'contexts'
  end

  def change
    reversible do |dir|
      dir.up do
        remove_column :contexts, :label
        remove_column :contexts, :description
      end

      dir.down do
        add_column :contexts, :label, :string, default: '', null: false
        add_column :contexts, :description, :text, default: '', null: false

        ActiveRecord::Base.transaction do
          MigrationContext.find_each do |ctx|
            ctx.update_columns(
              label: ctx.labels[default_locale],
              description: ctx.descriptions[default_locale]
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
