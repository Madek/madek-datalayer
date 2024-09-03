module Users
  module Filters
    extend ActiveSupport::Concern
    include FilterBySearchTerm

    included do
      scope :admins, -> { joins(:admin) }
      scope :activated, -> { where('now() <= active_until') }
      scope :deactivated, -> { where('now() > active_until') }
      scope :order_by, lambda { |attribute|
        case attribute.to_sym
        when :first_name_last_name
          reorder("first_name ASC NULLS FIRST, last_name ASC NULLS FIRST, email")
        else
          reorder(attribute)
        end
      }
    end

    class_methods do
      def filter_by(term,
                    search_also_in_person = false,
                    with_deactivated = false)
        result = with_deactivated ? all : activated
        exact_match = find_exact_matching(term, result)
        return exact_match if exact_match
        search_attributes = ['users.searchable']
        if search_also_in_person
          search_attributes << 'people.searchable'
          result = joins(:person)
        end
        result.filter_by_term_using_attributes(term, *search_attributes)
      end

      private

      def find_exact_matching(term, scope)
        # NOTE: should only be done for 'UNIQUE' columns!
        by_id = scope.where(id: term.split('/').last)
        return by_id if by_id.present?

        by_person_id = scope.where(person_id: term.split('/').last)
        return by_person_id if by_person_id.present?

        by_mail = scope.where(email: term)
        return by_mail if by_mail.present?
      end
    end
  end
end
