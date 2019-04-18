module Concerns
  module FindResource
    extend ActiveSupport::Concern

    module ClassMethods
      def find_or_build_resource!(val, meta_datum)
        # new resource to be created
        if val.is_a?(ActionController::Parameters)
          # using find_or_initialize_by due to the potential of being inside of a
          # transaction where the resource might just have been created
          find_or_initialize_by \
            meta_datum.sanitize_attributes_for_on_the_fly_resource_creation(val)
        # existing resource
        else
          find_resource!(val)
        end
      end

      # FIXME: still needed without Licenses?
      # can be overwritten for specific cases: see example license.rb
      # defaults to ActiveRecord::Base.find
      def find_resource!(val)
        id = val.try(:id) || val
        find(id)
      end
    end
  end
end
