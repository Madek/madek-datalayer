module Concerns
  module MediaResources
    module CustomOrderBy
      extend ActiveSupport::Concern

      module ClassMethods
        def custom_order_by(order_spec)
          case order_spec.downcase
          when 'created_at asc'
            reorder('created_at ASC')
          when 'created_at desc'
            reorder('created_at DESC')
          when 'title asc'
            joins_meta_data_title
              .reorder("meta_data.string ASC, #{table_name}.id ASC")
          when 'title desc'
            joins_meta_data_title
              .reorder("meta_data.string DESC, #{table_name}.id DESC")
          else
            raise 'Invalid order spec!'
          end
        end
      end
    end
  end
end
