class FinalizeVocabularyMigration < ActiveRecord::Migration[4.2]

  class Context < ActiveRecord::Base
  end

  def change
    change_column :meta_keys, :vocabulary_id, :string, null: false

    execute %q< ALTER TABLE vocabularies ADD CONSTRAINT vocabulary_id_chars CHECK (id ~* '^[a-z0-9\-\_]+$'); >
    execute %q< ALTER TABLE meta_keys ADD CONSTRAINT meta_key_id_chars CHECK (id ~* '^[a-z0-9\-\_\:]+$'); >
    execute %q< ALTER TABLE meta_keys ADD CONSTRAINT start_id_like_vocabulary_id CHECK (id like vocabulary_id || ':%' ); >

    # sanitize context ids:
    execute "SET session_replication_role = REPLICA"
    Context.all.each do |c|
      new_id = sanitize_namespace_id(c.id)
      execute "UPDATE meta_key_definitions" \
        " SET context_id = '#{new_id}' WHERE context_id = '#{c.id}'"
      c.update!(id: new_id)
    end
    execute "SET session_replication_role = DEFAULT"

    execute %q< ALTER TABLE contexts ADD CONSTRAINT context_id_chars CHECK (id ~* '^[a-z0-9\-\_]+$'); >
    remove_foreign_key :contexts, :context_groups
    remove_column :contexts, :position
    remove_index :contexts, :context_group_id
    remove_column :contexts, :context_group_id
    drop_table :context_groups
    # NOTE: implicit permissions by set are not migrated
    drop_table :media_sets_contexts

    # NOTE: to lessen confusion in the migrations before, rename
    #       `MetaKeyDefinitions` => `ContextKeys` here
    remove_foreign_key :meta_key_definitions, :meta_keys
    rename_table :meta_key_definitions, :context_keys
    add_foreign_key :context_keys, :meta_keys, on_delete: :cascade

  end

  # NOTE: copied from `151_migrate_meta_data_to_vocabulary`!
  def sanitize_namespace_id(str)
    str.downcase
      .gsub(/ä/, 'ae').gsub(/ö/, 'oe').gsub(/ü/, 'ue').gsub(/ß/, 'ss')
      .gsub(/\s+/, '_').gsub(/-/, '_').gsub(/_+/, '_').gsub(/[^a-z0-9\_\-]/, '')
  end


end
