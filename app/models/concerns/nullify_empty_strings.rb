module Concerns
  module NullifyEmptyStrings
    extend ActiveSupport::Concern

    module ClassMethods
      def nullify_empty(*args)
        before_validation do
          args.each do |attr|
            self[attr] = self[attr].presence
          end
        end
      end
    end
  end
end
