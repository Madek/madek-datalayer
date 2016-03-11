module Concerns
  module MetaKeys
    module Filters
      extend ActiveSupport::Concern

      included do
        scope :filter_by, lambda { |term|
          where(
            "setweight(to_tsvector('english', " \
                                  "coalesce(meta_keys.id, '')), " \
                      "'A') || " \
            "setweight(to_tsvector('english', " \
                                  "coalesce(meta_keys.label, '')), " \
                      "'A') || " \
            "setweight(to_tsvector('english', " \
                                  "coalesce(meta_keys.description, '')), " \
                      "'B') || " \
            "setweight(to_tsvector('english', " \
                                  "coalesce(meta_keys.hint, '')), " \
                      "'C') @@ " \
            "plainto_tsquery('english', ?)",
            term
          ).reorder(nil)
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
end
