module Concerns
  module MediaResources
    module CustomOrderBy
      extend ActiveSupport::Concern

      module ClassMethods
        def custom_order_by(order_spec)
          case order_spec
          when 'created_at ASC'
            reorder('created_at ASC')
          when 'created_at DESC'
            reorder('created_at DESC')
          when 'title ASC'
            joins_meta_data_title
              .reorder("meta_data.string ASC, #{table_name}.id ASC")
          when 'title DESC'
            joins_meta_data_title
              .reorder("meta_data.string DESC, #{table_name}.id DESC")
          when 'last_change'
            order_by_last_edit_session.reorder('last_change DESC')
          else
            raise 'Invalid order spec! ' + order_spec
          end
        end

        def joins_meta_data_title_by_classname
          single = self.name.underscore
          multiple = self.name.pluralize.underscore
          joins('INNER JOIN meta_data ' \
                'ON meta_data.' + single + '_id = ' + multiple + '.id ' \
                "AND meta_data.meta_key_id = 'madek_core:title'")
        end

        def order_by_last_edit_session_by_classname
          single = self.name.underscore
          multiple = self.name.pluralize.underscore
          select(
            <<-SQL
              #{multiple}.*,
              coalesce(
                max(edit_sessions.created_at),
                (#{multiple}.created_at - INTERVAL '1900 years')
              ) AS last_change
            SQL
          )
            .joins('INNER JOIN edit_sessions ' \
                  'ON edit_sessions.' + single + '_id = ' + multiple + '.id ')
            .group('' + multiple + '.id')
        end
      end
    end
  end
end
