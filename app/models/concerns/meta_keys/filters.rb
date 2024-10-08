module MetaKeys
  module Filters
    extend ActiveSupport::Concern

    included do
      scope :filter_by, lambda { |term|
        vector = <<-SQL
          setweight(
            to_tsvector('english', coalesce(meta_keys.id, '')), 'A') ||
          setweight(
            to_tsvector('english', coalesce(
              array_to_string(avals(meta_keys.labels), ' '), '')), 'A') ||
          setweight(
            to_tsvector('english', coalesce(
              array_to_string(avals(meta_keys.descriptions), ' '), '')), 'B') ||
          setweight(
            to_tsvector('english', coalesce(
              array_to_string(avals(meta_keys.hints), ' '), '')), 'C')
        SQL
        query = sanitize_sql_for_conditions(
          [
            "plainto_tsquery('english', '%s')",
            term
          ]
        )

        result =
          select('meta_keys.*', "ts_rank_cd(#{vector}, #{query}) AS search_rank")
            .where("#{vector} @@ #{query}", term)
            .reorder('search_rank DESC')

        # NOTE: the tsvector-based search does not match substrings ("desc"
        # should find "description"). As a workaround, we return simple
        # ILIKE-based results if the clever search did not find anything
        if result.blank?
          where_condition = <<-SQL
            id ILIKE :t
            OR
            coalesce(array_to_string(avals(labels), ' '), '') ILIKE :t
            OR
            coalesce(array_to_string(avals(descriptions), ' '), '') ILIKE :t
          SQL
          MetaKey.where(where_condition, t: "%#{term}%")
        else
          result
        end
      }
      scope :with_type, lambda { |type|
        where(meta_datum_object_type: type)
      }
      scope :of_vocabulary, lambda { |vocabulary_id|
        joins(:vocabulary)
          .where('vocabularies.id = :t', t: vocabulary_id)
      }
      scope :not_in_context, lambda { |context|
        where(
          'NOT EXISTS (SELECT 1 FROM context_keys
            WHERE context_keys.context_id = ?
            AND context_keys.meta_key_id = meta_keys.id)',
          context.id
        )
      }
    end
  end
end
