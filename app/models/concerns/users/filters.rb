module Concerns
  module Users
    module Filters
      extend ActiveSupport::Concern
      include Concerns::FilterBySearchTerm

      included do
        scope :admin_users, -> { joins(:admin) }
        scope :filter_by, lambda { |term, search_also_in_person = false|
          result = all
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
      end
    end
  end
end
