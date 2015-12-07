module Concerns
  module MediaResources
    module CustomUrls
      extend ActiveSupport::Concern

      included do
        has_many :custom_urls

        # overrides ActiveRecord::Base#to_param
        def to_param
          custom_urls.find_by(is_primary: true).try(:to_param) or super
        end
      end
    end
  end
end
