module ApiClients
  module Filters
    extend ActiveSupport::Concern

    include FilterBySearchTerm

    module ClassMethods
      def filter_by(term)
        filter_by_term_using_attributes(term, :login)
      end
    end

  end
end
