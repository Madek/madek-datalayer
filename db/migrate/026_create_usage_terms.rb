class CreateUsageTerms < ActiveRecord::Migration[4.2]
  include Madek::MigrationHelper

  def change
    create_table :usage_terms, id: false do |t|
      t.primary_key :id, :uuid, default: 'gen_random_uuid()'
      t.string :title
      t.string :version
      t.text :intro
      t.text :body
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        set_timestamps_defaults :usage_terms
      end
    end
  end
end
