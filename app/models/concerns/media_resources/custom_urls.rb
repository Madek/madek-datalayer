module MediaResources
  module CustomUrls
    extend ActiveSupport::Concern

    included do
      has_many :custom_urls

      # overrides ActiveRecord::Base#to_param
      def to_param
        custom_urls.find_by(is_primary: true).try(:to_param) or super
      end

      # Use this instead of `find_by_id` to lookup the resource not only by id, but also by custom url id (returns nil when not found)
      def self.find_by_id_or_custom_url_id(arg)
        if arg.is_a?(String) and not arg.match UUIDTools::UUID_REGEXP
          joins(:custom_urls).where(custom_urls: { id: arg }).first
        else
          where(id: arg).first
        end
      end

      # Use this instead of `find` to lookup the resource not only by id, but also by custom url id (throws ActiveRecord::RecordNotFound when not found)
      def self.find_by_id_or_custom_url_id_or_raise(arg)
        find_by_id_or_custom_url_id(arg) or raise ActiveRecord::RecordNotFound
      end
    end
  end
end
