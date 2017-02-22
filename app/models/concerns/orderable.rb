module Concerns
  module Orderable
    extend ActiveSupport::Concern

    module ClassMethods
      def enable_ordering(skip_default_scope: false, parent_scope: nil)
        @_parent_scope = parent_scope
        define_method :move do |direction, scope = {}|
          ActiveRecord::Base.transaction do
            regenerate_positions(scope: scope)
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

      def parent_scope
        @_parent_scope
      end
    end

    included do
      before_create do
        self.position =
          begin
            if parent_scope = self.class.parent_scope
              compute_parent_scope(parent_scope).maximum(:position) + 1
            else
              self.class.maximum(:position) + 1
            end
          rescue
            0
          end
      end

      after_create :regenerate_positions
    end

    def regenerate_positions(scope: {})
      siblings =
        if parent_scope = self.class.parent_scope
          compute_parent_scope(parent_scope)
        else
          self.class.where(scope)
        end
      siblings.each_with_index do |obj, i|
        obj.update_attribute :position, i
      end
      reload
    end

    private

    def compute_parent_scope(parent_scope)
      send(parent_scope).send(self.class.to_s.underscore.pluralize)
    end
  end
end
