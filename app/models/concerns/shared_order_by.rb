module Concerns
  module SharedOrderBy
    extend ActiveSupport::Concern

    included do
      def self.joins_meta_data_title_by_classname
        single = self.name.underscore
        multiple = self.name.pluralize.underscore
        joins('INNER JOIN meta_data ' \
              'ON meta_data.' + single + '_id = ' + multiple + '.id ' \
              "AND meta_data.meta_key_id = 'madek_core:title'")
      end

      def self.order_by_last_edit_session_by_classname
        multiple = self.name.pluralize.underscore
        select(
          <<-SQL
            #{multiple}.*,
            #{multiple}.edit_session_updated_at AS last_change
          SQL
        )
      end
    end
  end
end
