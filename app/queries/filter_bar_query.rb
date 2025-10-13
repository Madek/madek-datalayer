# This implements an efficient query for MetaData in the DynamicFilters presenter
# Takes an (ActiveRecord) `Scope` and a list of `Context` IDs.
# Returns for each `Context` a list of the MetaKeys "used" in `Scope`,
# and for each MetaKey a list of the "used" Values,
# along with and sorted by "usage count".
# - "used" refers to the related MetaData of the Resources in `Scope`
# - "Values" can be Keywords and People
#
# NOTES:
# - USE WITH CARE - never use this with user input (SQL injection 👻)
# - only returns *publicly visible* data
#   (i.e. does not fully implement Vocabulary.Permissions)
# - does NOT limit anything (worst case in production is currently fast enough)

# rubocop:disable all
class FilterBarQuery < ActiveRecord::Base

  def self.meta_data_sql_query(type, init_scope, contexts, user_id, opts)
    if user_id
      user_id = UUIDTools::UUID.parse(user_id)
    end
    singular = type.name.underscore
    plural = singular.pluralize

    permissions_part = ''
    if user_id
      permissions_part = <<-SQL
        OR EXISTS (
          SELECT * FROM vocabulary_user_permissions
          WHERE vocabulary_user_permissions.vocabulary_id = vocabularies.id
          AND vocabulary_user_permissions.user_id = '#{user_id}'
          AND vocabulary_user_permissions.view = true
        )
        OR EXISTS(
          SELECT * FROM vocabulary_group_permissions, groups_users
          WHERE vocabulary_group_permissions.vocabulary_id = vocabularies.id
          AND vocabulary_group_permissions.group_id = groups_users.group_id
          AND vocabulary_group_permissions.view = true
          AND groups_users.user_id = '#{user_id}'
        )
      SQL
    end

    context_key_id = if ck_id = opts[:context_key_id]
                       UUIDTools::UUID.parse(ck_id)
                     end
    context_key_id_part = if context_key_id.presence
                            "AND context_keys.id = '#{context_key_id}'" 
                          end
    search_term = opts[:search_term].presence
    search_term_part = if search_term
                         sanitize_sql(["WHERE label ILIKE '%s'", "%#{search_term}%"])
                       end

    <<-SQL
      WITH with_#{plural} AS
        (#{init_scope.reorder(nil).to_sql}),
           with_metadata AS
        (SELECT contexts.id AS context_id,
                context_keys.id AS context_key_id,
                meta_keys.meta_datum_object_type AS meta_datum_type,
                meta_data.id AS meta_data_id,
                meta_data.#{singular}_id AS #{singular}_id
         FROM contexts
         INNER JOIN context_keys ON context_keys.context_id = contexts.id #{context_key_id_part}
         INNER JOIN meta_keys ON context_keys.meta_key_id = meta_keys.id
         INNER JOIN meta_data ON meta_data.meta_key_id = meta_keys.id
                AND meta_data.string IS NULL
         INNER JOIN vocabularies ON meta_keys.vocabulary_id = vocabularies.id
         AND (
           vocabularies.enabled_for_public_view IS TRUE
           #{permissions_part}
         )
         WHERE contexts.id IN (#{contexts.map { |c| "'#{c.id}'" }.join(', ')})),

      with_joined_data AS
      (
          SELECT with_metadata.*
          FROM with_metadata
          INNER JOIN with_#{plural}
            ON with_#{plural}.id = with_metadata.#{singular}_id
      )
      SELECT *
      FROM
        (SELECT with_joined_data.context_id,
                with_joined_data.context_key_id,
                COUNT(with_joined_data.#{singular}_id) AS count,
                keywords.id AS uuid,
                keywords.term AS label,
                'keyword' AS type
         FROM with_joined_data
         INNER JOIN meta_data_keywords ON meta_data_keywords.meta_datum_id = with_joined_data.meta_data_id
         INNER JOIN keywords ON meta_data_keywords.keyword_id = keywords.id
         GROUP BY keywords.id,
                  with_joined_data.context_key_id,
                  with_joined_data.context_id

         UNION SELECT with_joined_data.context_id,
                      with_joined_data.context_key_id,
                      COUNT(with_joined_data.#{singular}_id) AS count,
                      people.id AS uuid,
                      people.searchable AS label,
                      'person' AS type
         FROM with_joined_data
         INNER JOIN meta_data_people ON meta_data_people.meta_datum_id = with_joined_data.meta_data_id
         INNER JOIN people ON meta_data_people.person_id = people.id
         GROUP BY people.id,
                  with_joined_data.context_key_id,
                  with_joined_data.context_id

        UNION SELECT with_joined_data.context_id,
                     with_joined_data.context_key_id,
                     COUNT(with_joined_data.#{singular}_id) AS count,
                     roles.id AS uuid,
                     roles.labels->'#{I18n.locale}' AS label,
                     'role' AS type
        FROM with_joined_data
        INNER JOIN meta_data_people ON meta_data_people.meta_datum_id = with_joined_data.meta_data_id
        INNER JOIN roles ON meta_data_people.role_id = roles.id
        GROUP BY roles.id,
                 with_joined_data.context_key_id,
                 with_joined_data.context_id
        ) AS t1

      #{search_term_part}
      ORDER BY count DESC, label ASC
    SQL
  end

  def self.media_types_sql_query(init_scope)
    <<-SQL
      SELECT media_files.media_type AS label,
             media_files.media_type AS uuid,
             count(media_files.media_type) AS count
      FROM media_files
      WHERE media_files.media_entry_id IN (#{init_scope.select(:id).reorder(nil).to_sql})
      GROUP BY media_files.media_type
      HAVING NOT media_files.media_type = ''
      ORDER BY count DESC
    SQL
  end

  def self.extensions_sql_query(init_scope)
    <<-SQL
      SELECT media_files.extension AS label,
             media_files.extension AS uuid,
             count(media_files.extension) AS count
      FROM "media_files"
      WHERE media_files.media_entry_id IN (#{init_scope.select(:id).reorder(nil).to_sql})
      GROUP BY media_files.extension
      HAVING NOT media_files.extension = ''
      ORDER BY count DESC
    SQL
  end

  def self.get_metadata_unsafe(type, init_scope, contexts, user, opts = {})
    user_id = user ? user.id : nil
    run meta_data_sql_query(type, init_scope, contexts, user_id, opts)
  end

  def self.get_extensions_unsafe(init_scope)
    run extensions_sql_query(init_scope)
  end

  def self.get_media_types_unsafe(init_scope)
    run media_types_sql_query(init_scope)
  end

  private_class_method

  def self.run(query)
    connection.exec_query(query).to_a
  end
end
# rubocop:enable all
