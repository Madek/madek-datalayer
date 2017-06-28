module Concerns
  module OrderMethods
    extend ActiveSupport::Concern
    included do
      def self.define_up_and_down
        %i(up down).each do |direction|
          define_method "move_#{direction}" do |scope = {}|
            ActiveRecord::Base.transaction do
              regenerate_positions
              new_position =
                case direction
                when :up then position - 1
                when :down then position + 1
                end
              if new_position && \
                 (sibling = get_sibling(new_position))
                sibling.update_attribute(:position, position)
                update_attribute(:position, new_position)
              end
            end
          end
        end
      end

      def self.define_to_top
        define_method :move_to_top do |scope = {}|
          ActiveRecord::Base.transaction do
            regenerate_positions
            new_position = 0

            get_siblings(operator: '<').each do |sibling|
              sibling.increment(:position)
              sibling.save!
            end
            update_attribute(:position, new_position)
          end
        end
      end

      def self.define_to_bottom
        define_method :move_to_bottom do |scope = {}|
          ActiveRecord::Base.transaction do
            regenerate_positions
            new_position = max_position
            get_siblings(operator: '>').each do |sibling|
              sibling.decrement(:position)
              sibling.save!
            end
            update_attribute(:position, new_position)
          end
        end
      end
    end

    private

    def get_sibling(new_position)
      sibling = self.class.where(position: new_position)
      if parent_scope = self.class.parent_scope
        sibling = sibling
                    .where(parent_scope => send(parent_scope))
      end
      sibling.first
    end

    def get_siblings(operator:)
      siblings =
        self
          .class
          .where("#{self.class.table_name}.position #{operator} ?", position)
      if parent_scope = self.class.parent_scope
        siblings = siblings
                     .where(parent_scope => send(parent_scope))
      end
      siblings
    end

    def max_position
      (
        if parent_scope = self.class.parent_scope
          self.class.where(parent_scope => send(parent_scope))
        else
          self.class.all
        end
      ).maximum(:position)
    end
  end
end
