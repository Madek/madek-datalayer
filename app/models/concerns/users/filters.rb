module Concerns
  module Users
    module Filters
      extend ActiveSupport::Concern
      include Concerns::FilterBySearchTerm

      included do
        scope :admin_users, -> { joins(:admin) }

        scope :filter_by, lambda { |term, search_also_in_person = false|
          result = where(is_deactivated: false)
          exact_match = self.find_exact_matching(term, result)
          return exact_match if exact_match
          search_attributes = ['users.searchable']
          if search_also_in_person
            search_attributes << 'people.searchable'
            result = joins(:person)
          end
          result.filter_by_term_using_attributes(term, *search_attributes)
        }

        scope :sort_by, lambda { |attribute|
          case attribute.to_sym
          when :first_name_last_name
            joins(:person)
              .reorder('people.searchable ASC')
          else
            reorder(attribute)
          end
        }

        private

        def self.find_exact_matching(term, scope)
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
end
