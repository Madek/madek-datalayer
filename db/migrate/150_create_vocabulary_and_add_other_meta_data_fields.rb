class CreateVocabularyAndAddOtherMetaDataFields < ActiveRecord::Migration[4.2]

  def change
    rename_column :meta_keys, :meta_terms_alphabetical_order, :keywords_alphabetical_order

    # from meta_keys_definitions
    #
    add_column :meta_keys, :label, :text
    add_column :meta_keys, :description, :text
    add_column :meta_keys, :hint, :text
    add_column :meta_keys, :position, :integer

    # Scope
    add_column :meta_keys, :is_enabled_for_media_entries, :bool, null: false, default: false
    add_column :meta_keys, :is_enabled_for_collections, :bool, null: false, default: false
    add_column :meta_keys, :is_enabled_for_filter_sets, :bool, null: false, default: false

    # Vocabulary
    create_table :vocabularies, id: :string do |t|
      t.text :label
      t.text :description
      t.boolean :enabled_for_public_view, default: true, null: false
      t.boolean :enabled_for_public_use, default: true, null: false
    end

    add_column :meta_keys, :vocabulary_id, :string

#    create_table :vocables, id: false do |t|
#      t.primary_key :id, :uuid, default: 'gen_random_uuid()'
#      t.string :meta_key_id
#      t.index :meta_key_id
#
#      t.text :term
#    end
#
#    create_table :meta_data_vocables, id: false do |t|
#      t.uuid :meta_datum_id
#      t.uuid :vocable_id
#      t.index [:meta_datum_id, :vocable_id], unique: true
#      t.index [:vocable_id, :meta_datum_id]
#    end

    add_column :keyword_terms, :meta_key_id, :string
    add_index :keyword_terms, :meta_key_id

    add_column :meta_keys, :is_extensible, :bool, default: false
  end

end
