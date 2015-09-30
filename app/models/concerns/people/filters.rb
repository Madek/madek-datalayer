module Concerns
  module People
    module Filters
      extend ActiveSupport::Concern

      included do
        scope :with_user, -> { joins(:user) }
        scope :search_by_term, lambda { |term|
          where('first_name ILIKE :t OR last_name ILIKE :t', t: "%#{term}%")
        }
      end

      # person admin stuff:
      include Concerns::FilterBySearchTerm

      module ClassMethods
        def filter_by(term)
          filter_by_term_using_attributes(term, :searchable)
        end
      end

    end
  end
end
