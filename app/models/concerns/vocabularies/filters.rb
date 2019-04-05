module Concerns
  module Vocabularies
    module Filters
      extend ActiveSupport::Concern

      included do
        scope :filter_by, lambda { |term|
          where(
            sanitize_sql_for_conditions(
              [
                "vocabularies.id ILIKE '%s' OR " \
                "array_to_string(avals(vocabularies.labels), '||') ILIKE '%s'",
                "%#{term}%",
                "%#{term}%"
              ]
            )
          )
        }
        scope :ids_for_filter, -> { order(:id).pluck(:id) }
        scope :viewable_by_public, -> { where(enabled_for_public_view: true) }
      end
    end
  end
end
