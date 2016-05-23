module Concerns
  module FindResource
    extend ActiveSupport::Concern

    module ClassMethods
      def find_or_build_resource!(val, meta_datum)
        if val.is_a?(Hash)
          new \
            meta_datum.sanitize_attributes_for_on_the_fly_resource_creation(val)
        else
          find_resource!(val)
        end
      end

      # can be overwritten for specific cases: see example license.rb
      # defaults to ActiveRecord::Base.find
      def find_resource!(val)
        find(val)
      end
    end
  end
end
