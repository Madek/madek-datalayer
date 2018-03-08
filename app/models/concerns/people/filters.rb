module Concerns
  module People
    module Filters
      extend ActiveSupport::Concern

      # person admin stuff:
      include Concerns::FilterBySearchTerm

      module ClassMethods
        def filter_by(meta_key_id, term = nil)
          result = where(
            subtype: MetaKey.find(meta_key_id).allowed_people_subtypes
          )
          exact_match = self.find_exact_matching(term, result) if term
          return exact_match if exact_match
          if term
            result = result.filter_by_term_using_attributes(term, :searchable)
          end
          result
        end
      end

      included do
        scope :with_user, -> { joins(:user) }
        scope :search_by_term, lambda { |term|
          where('people.searchable ILIKE :t', t: "%#{term}%")
        }

        private

        def self.find_exact_matching(term, scope)
          # NOTE: should only be done for 'UNIQUE' columns!
          by_id = scope.where(id: term.split('/').last)
          return by_id if by_id.present?
        end

      end

    end
  end
end
