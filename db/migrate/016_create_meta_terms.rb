class CreateMetaTerms < ActiveRecord::Migration[4.2]
  include Madek::MigrationHelper

  def change
    create_table :meta_terms, id: false do |t|
      t.primary_key :id, :uuid, default: 'gen_random_uuid()'
      t.text :term, null: false, default: ''
      t.index :term, unique: true
    end

    reversible do |dir|
      dir.up do
        create_trgm_index :meta_terms, :term
        create_text_index :meta_terms, :term
      end
    end
  end

end
