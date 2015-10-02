module Concerns
  module FindResource
    extend ActiveSupport::Concern

    module ClassMethods
      def find_resource!(val)
        find(val)
      end
    end
  end
end
