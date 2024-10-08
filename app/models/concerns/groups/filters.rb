module Groups
  module Filters
    extend ActiveSupport::Concern

    included do

      scope :filter_by, lambda{ |search_term, filter = nil, _scope = nil|
        default_query(search_term, filter)
      }

      def self.default_query(search_term, filter)
        case filter
        when 'trgm_rank'
          if search_term.blank?
            raise ArgumentError, 'Search term must not be blank!'
          else
            trgm_rank_search(search_term) \
              .order('name ASC, institutional_name ASC')
          end
        when 'text_rank'
          if search_term.blank?
            raise ArgumentError, 'Search term must not be blank!'
          else
            text_rank_search(search_term) \
              .order('name ASC, institutional_name ASC')
          end
        else
          text_search(search_term) \
            .order('name ASC, institutional_name ASC') \
              unless search_term.blank?
        end
      end
    end
  end
end
