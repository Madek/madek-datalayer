class CreateVocabularyPermissions < ActiveRecord::Migration[4.2]
  def change

    %w(user api_client group).each do |entity|
      create_table "vocabulary_#{entity}_permissions", id: false do |t|
      t.primary_key :id, :uuid, default: 'gen_random_uuid()'
        t.uuid "#{entity}_id", null: false
        t.string :vocabulary_id, null: false
        t.index ["#{entity}_id",:vocabulary_id], name: "idx_vocabulary_#{entity}",unique: true
        t.boolean :use, default: false, null: false
        t.boolean :view, default: true, null: false
      end

      add_foreign_key "vocabulary_#{entity}_permissions", "#{entity.pluralize}", on_delete: :cascade
      add_foreign_key "vocabulary_#{entity}_permissions", :vocabularies, on_delete: :cascade
    end

    # set permissions for orphans (hide them)
    execute %q< UPDATE vocabularies SET enabled_for_public_view = '0', enabled_for_public_use = '0' WHERE id = 'madek_orphans'; >
  end

end
