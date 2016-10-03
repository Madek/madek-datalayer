module Concerns
  module People
    module Filters
      extend ActiveSupport::Concern

      included do
        scope :with_user, -> { joins(:user) }
        scope :search_by_term, lambda { |term|
          where('searchable ILIKE :t', t: "%#{term}%")
        }
      end

      # person admin stuff:
      include Concerns::FilterBySearchTerm

      module ClassMethods
        def filter_by(meta_key_id, term = nil)
          result = where(
            subtype: MetaKey.find(meta_key_id).allowed_people_subtypes
          )
          if term
            result = result.filter_by_term_using_attributes(term, :searchable)
          end
          result
        end
      end

    end
  end
end
