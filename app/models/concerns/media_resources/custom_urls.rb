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

        # this provides customized `find` and `find_by_id` methods
        # on the model class itself:
        # eg. Collection.find('custom_id or uuid')
        # it also prevents the use of `find_by` and `find_by!`
        extend Concerns::MediaResources::CustomUrls::Finders
        class << self
          alias_method :find_without_custom_id, :find
          alias_method :find, :find_with_custom_id
        end

        # this provides customized `find` and `find_by_id` methods
        # on the model relation, so that they work also when chained
        # after other AR methods:
        # eg. Collection
        #       .joins(:custom_urls)
        #       .where(custom_urls: { is_primary: true })
        #       .find('custom_id')
        # it also prevents the use of `find_by` and `find_by!`
        const_get(:ActiveRecord_Relation).class_eval do
          include Concerns::MediaResources::CustomUrls::Finders
        end
      end
    end
  end
end
