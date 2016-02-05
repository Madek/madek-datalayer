# rubocop:disable all
class FilterBarQuery < ActiveRecord::Base

  def self.sql_query(init_scope, context_ids)

    <<SQL
WITH with_media_entries AS
  (#{init_scope.reorder(nil).to_sql}),
     with_joined_data AS
  (SELECT contexts.id AS context_id,
          context_keys.id AS context_key_id,
          meta_keys.meta_datum_object_type AS meta_datum_type,
          meta_data.id AS meta_data_id,
          meta_data.media_entry_id AS media_entry_id
   FROM contexts
   INNER JOIN context_keys ON context_keys.context_id = contexts.id
   INNER JOIN meta_keys ON context_keys.meta_key_id = meta_keys.id
   INNER JOIN meta_data ON meta_data.meta_key_id = meta_keys.id
   AND meta_data.string IS NULL
   INNER JOIN vocabularies ON meta_keys.vocabulary_id = vocabularies.id
   AND vocabularies.enabled_for_public_view IS TRUE
   WHERE meta_data.media_entry_id IN (SELECT id FROM with_media_entries)
     AND contexts.id IN (#{context_ids.map { |s| "'#{s}'" }.join(', ')}))
SELECT *
FROM
  (SELECT with_joined_data.context_id,
          with_joined_data.context_key_id,
          COUNT(with_joined_data.media_entry_id) AS count,
          keywords.id AS resource_id,
          keywords.term AS value
   FROM with_joined_data
   INNER JOIN meta_data_keywords ON meta_data_keywords.meta_datum_id = with_joined_data.meta_data_id
   INNER JOIN keywords ON meta_data_keywords.keyword_id = keywords.id
   GROUP BY keywords.id,
            with_joined_data.context_key_id,
            with_joined_data.context_id
   UNION SELECT with_joined_data.context_id,
                with_joined_data.context_key_id,
                COUNT(with_joined_data.media_entry_id) AS count,
                licenses.id AS resource_id,
                licenses.label AS value
   FROM with_joined_data
   INNER JOIN meta_data_licenses ON meta_data_licenses.meta_datum_id = with_joined_data.meta_data_id
   INNER JOIN licenses ON meta_data_licenses.license_id = licenses.id
   GROUP BY licenses.id,
            with_joined_data.context_key_id,
            with_joined_data.context_id
   UNION SELECT with_joined_data.context_id,
                with_joined_data.context_key_id,
                COUNT(with_joined_data.media_entry_id) AS count,
                groups.id,
                groups.name AS value
   FROM with_joined_data
   INNER JOIN meta_data_groups ON meta_data_groups.meta_datum_id = with_joined_data.meta_data_id
   INNER JOIN groups ON meta_data_groups.group_id = groups.id
   GROUP BY groups.id,
            with_joined_data.context_key_id,
            with_joined_data.context_id
   UNION SELECT with_joined_data.context_id,
                with_joined_data.context_key_id,
                COUNT(with_joined_data.media_entry_id) AS count,
                people.id AS resource_id,
                people.searchable AS value
   FROM with_joined_data
   INNER JOIN meta_data_people ON meta_data_people.meta_datum_id = with_joined_data.meta_data_id
   INNER JOIN people ON meta_data_people.person_id = people.id
   GROUP BY people.id,
            with_joined_data.context_key_id,
            with_joined_data.context_id ) AS t1
  ORDER BY count DESC
SQL

  end

  def self.get(init_scope, context_ids)
    query = sql_query(init_scope, context_ids)
    @result ||= \
      connection
        .exec_query(query)
        .to_hash
  end

  def self.reset
    @result = nil
  end
end
# rubocop:enable all
