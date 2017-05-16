module Concerns
  module MediaResources
    module CustomOrderBy
      extend ActiveSupport::Concern

      module ClassMethods
        def custom_order_by(order_spec, join_meta_data_for_order: true)
          case order_spec
          when 'created_at ASC'
            reorder('created_at ASC')
          when 'created_at DESC'
            reorder('created_at DESC')
          when 'title ASC'
            joins_meta_data_title_with_projection(join_meta_data_for_order)
              .reorder("meta_data.string ASC, #{table_name}.id ASC")
          when 'title DESC'
            joins_meta_data_title_with_projection(join_meta_data_for_order)
              .reorder("meta_data.string DESC, #{table_name}.id DESC")
          when 'last_change'
            order_by_last_edit_session.reorder('last_change DESC')
          else
            raise 'Invalid order spec! ' + order_spec
          end
        end

        private

        def joins_meta_data_title_with_projection(join_meta_data_for_order)
          if join_meta_data_for_order
            joins_meta_data_title
          else
            all
          end
            .select(all.arel.project('meta_data.string').projections)
        end
      end
    end
  end
end
