class MigrateMetaDataToVocabulary < ActiveRecord::Migration[4.2]

  class IoMapping < ActiveRecord::Base
    belongs_to :meta_key
  end

  class MetaTerm < ActiveRecord::Base
    has_and_belongs_to_many :meta_keys
  end

  class MetaKey < ActiveRecord::Base
    has_and_belongs_to_many :meta_terms
    has_many :meta_data
    belongs_to :vocabulary
    has_many :meta_key_definitions
    has_many :contexts, through: :meta_key_definitions
    has_many :io_mappings, dependent: :destroy
  end

  class MetaKeyDefinition < ActiveRecord::Base
    belongs_to :context, foreign_key: :context_id
    belongs_to :meta_key
  end

  class Context < ActiveRecord::Base
    has_many :meta_key_definitions
  end

  class ContextGroup < ActiveRecord::Base
  end

  class MetaDatum < ActiveRecord::Base
    self.inheritance_column = false

    has_and_belongs_to_many :users,
      join_table: :meta_data_users,
      foreign_key: :meta_datum_id,
      association_foreign_key: :user_id

    has_and_belongs_to_many :vocables,
      join_table: :meta_data_vocables,
      foreign_key: :meta_datum_id,
      association_foreign_key: :vocable_id

    has_and_belongs_to_many :meta_terms,
      join_table: :meta_data_meta_terms,
      foreign_key: :meta_datum_id,
      association_foreign_key: :meta_term_id

    has_and_belongs_to_many :people,
      join_table: :meta_data_people,
      foreign_key: :meta_datum_id,
      association_foreign_key: :person_id

    has_and_belongs_to_many :groups,
      join_table: :meta_data_groups,
      foreign_key: :meta_datum_id,
      association_foreign_key: :group_id

    has_many :keywords

    belongs_to :meta_key
  end

  class Person < ActiveRecord::Base
  end

  class Vocabulary < ActiveRecord::Base
    has_many :meta_keys
    has_many :vocables, through: :meta_keys
  end

  class Keyword < ActiveRecord::Base
    belongs_to :keyword_term
    belongs_to :meta_datum_keywords
  end

  class KeywordTerm < ActiveRecord::Base
    has_many :keyword_terms
  end


  def change
    begin
      KeywordTerm.reset_column_information
      Vocabulary.reset_column_information
      MetaKey.reset_column_information
      MetaDatum.reset_column_information
      MetaTerm.reset_column_information
      MetaKeyDefinition.reset_column_information

      # only required on meta_keys themselves:
      change_column_null :meta_key_definitions, :label, true
      change_column_null :meta_key_definitions, :description, true
      change_column_null :meta_key_definitions, :hint, true

      # add admin comments
      add_column(:vocabularies, :admin_comment, :text, null: true)
      add_column(:contexts, :admin_comment, :text, null: true)
      add_column(:meta_keys, :admin_comment, :text, null: true)
      add_column(:meta_key_definitions, :admin_comment, :text, null: true)

      orphan_vocabulary = Vocabulary.find_or_create_by(id:'madek_orphans', label: 'Orphans',
        description: 'The related meta_keys in this vocabulary were not related to any context before the migration.')


      second_context_group = ContextGroup.reorder(:position).second

      MetaKey.order(:id).each do |meta_key|
        # Find Context to base new Vocabulary on (and the associated MKDef)
        if meta_key.meta_key_definitions.count == 0
          meta_key_definition = nil
          vocabulary = orphan_vocabulary
        else
          # Find "prefered" context, use it as base for new vocabulary!
          # The following works in the general case, and can be "cleaned up" by an admin pre migration (in UI).
          # - find or create Contexts that should become Vocabularies
          # - make sure each MetaKey is used only once as a MetaKeyDefinition in all of those Contexts
          # - put only those Context in a ContextGroup
          meta_key_definition = meta_key.meta_key_definitions
            .sort_by {|mkd| mkd.context.context_group_id || '❌'}.first
          context = meta_key_definition.context

          is_public = context.context_group_id != second_context_group.id

          # create vocabulary based on context:
          vocabulary = Vocabulary.find_or_create_by(id: sanitize_namespace_id(context.id))
          vocabulary.update_attributes(
            enabled_for_public_view: is_public,
            enabled_for_public_use: is_public,
            label: context.label,
            description: context.description,
            admin_comment: "[Created automatically from Context '#{context.label}']")
        end

        old_meta_key_id = meta_key.id.to_s
        new_meta_key_id = "#{vocabulary.id}:#{sanitize_meta_key_id(meta_key.id)}"

        new_meta_key_attributes = { # new columns:
                                    is_enabled_for_collections: enabled_for_collections?(meta_key_definition),
                                    is_enabled_for_media_entries: true,
                                    # new vocabulary:
                                    vocabulary_id: vocabulary.id,
                                    # new id schema:
                                    id: new_meta_key_id }
        # merge some attributes from MKD (if not orphan)
        if meta_key_definition.present?
          # *move* 'label', 'description' and 'hint'; only *copy* 'position'
          new_meta_key_attributes.merge!(
            label: meta_key_definition.label,
            description: meta_key_definition.description,
            hint: meta_key_definition.label,
            position: meta_key_definition.position)
          meta_key_definition.update!(label: nil, description: nil, hint: nil)
        end


        Rails.logger.info "LINKING META_KEY: #{new_meta_key_attributes}"
        # disable db constraints while rewriting (foreign) keys:
        execute "SET session_replication_role = REPLICA"

        meta_key.update!(new_meta_key_attributes)

        execute "UPDATE meta_key_definitions" \
          " SET meta_key_id = '#{new_meta_key_id}'" \
          " WHERE meta_key_id = '#{old_meta_key_id}'"

        execute "UPDATE meta_data" \
          " SET meta_key_id = '#{new_meta_key_id}'" \
          " WHERE meta_key_id = '#{old_meta_key_id}'"

        # keywords - TODO: what about unused keywords?
        meta_key.meta_data.each do |meta_datum|
          migrate_meta_terms(meta_datum, new_meta_key_id)
        end

        execute "UPDATE io_mappings" \
          " SET meta_key_id = '#{new_meta_key_id}'" \
          " WHERE meta_key_id = '#{old_meta_key_id}'"

        execute "SET session_replication_role = DEFAULT" # re-enable db constraints
      end

    rescue Exception => e
      Rails.logger.warn "#{e.class} #{e.message} #{e.backtrace.join(', ')}"
      raise e
    end
  end

  def sanitize_namespace_id(str)
    str.downcase
      .gsub(/ä/, 'ae').gsub(/ö/, 'oe').gsub(/ü/, 'ue').gsub(/ß/, 'ss')
      .gsub(/\s+/, '_').gsub(/-/, '_').gsub(/_+/, '_').gsub(/[^a-z0-9\_\-]/, '')
  end

  def sanitize_meta_key_id(str)
    str.downcase
      .gsub(/ä/, 'ae').gsub(/ö/, 'oe').gsub(/ü/, 'ue').gsub(/ß/, 'ss')
      .gsub(/\s+/, '_').gsub(/[^a-z0-9\-\_]/,'_').gsub(/-/, '_').gsub(/_+/, '_')
  end

  def migrate_meta_terms(meta_datum, new_meta_key_id)
    meta_datum.meta_terms.each do |meta_term|
      keyword_term = KeywordTerm.find_or_create_by(term: meta_term.term, meta_key_id: new_meta_key_id)
      Keyword.find_or_create_by meta_datum_id: meta_datum.id, keyword_term_id: keyword_term.id
    end
    meta_datum.keywords.reset
  end

  def enabled_for_collections?(meta_key_definition)
    return false unless meta_key_definition.present?
    !!(meta_key_definition.context_id =~ /media_set/)
  end

end
