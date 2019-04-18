class CreateMetaKeysMetaTerms < ActiveRecord::Migration[4.2]

  def change
    create_table :meta_keys_meta_terms, id: false do |t|
      t.primary_key :id, :uuid, default: 'gen_random_uuid()'
      t.string :meta_key_id, null: false
      t.index :meta_key_id

      t.uuid :meta_term_id, null: false

      t.index [:meta_key_id, :meta_term_id], unique: true

      t.integer :position, default: 0, null: false
      t.index :position
    end

    add_foreign_key :meta_keys_meta_terms, :meta_keys, on_delete: :cascade
    add_foreign_key :meta_keys_meta_terms, :meta_terms, on_delete: :cascade
  end

end
