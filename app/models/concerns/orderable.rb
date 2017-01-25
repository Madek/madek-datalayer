module Concerns
  module Orderable
    extend ActiveSupport::Concern

    module ClassMethods
      def enable_ordering(skip_default_scope: false)
        define_method :move do |direction, scope = {}|
          ActiveRecord::Base.transaction do
            regenerate_positions(scope)
            new_position =
              case direction
              when :up then position - 1
              when :down then position + 1
              end
            if new_position && \
               (sibling = \
                  self.class.find_by({ position: new_position }.merge(scope)))
              sibling.update_attribute(:position, position)
              update_attribute(:position, new_position)
            end
          end
        end

        unless skip_default_scope
          default_scope { order(:position) }
        end
      end
    end

    private

    def regenerate_positions(scope = {})
      self.class.where(scope).each_with_index do |obj, i|
        obj.update_attribute :position, i
      end
      reload
    end
  end
end
