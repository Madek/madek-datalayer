module MediaResources
  module CustomUrls
    extend ActiveSupport::Concern

    included do
      has_many :custom_urls

      # overrides ActiveRecord::Base#to_param
      def to_param
        custom_urls.find_by(is_primary: true).try(:to_param) or super
      end

      def self.find_by_id_or_custom_url_id(arg)
        if arg.is_a?(String) and not arg.match UUIDTools::UUID_REGEXP
          joins(:custom_urls).where(custom_urls: { id: arg }).first
        else
          where(id: arg).first
        end
      end
    end
  end
end
