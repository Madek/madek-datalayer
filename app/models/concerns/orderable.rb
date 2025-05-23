module Orderable
  extend ActiveSupport::Concern
  include OrderMethods

  module ClassMethods
    def enable_ordering(skip_default_scope: false, parent_scope: nil, parent_child_relation: nil)
      @_parent_scope = parent_scope
      @_parent_child_relation = parent_child_relation

      define_up_and_down
      define_to_top
      define_to_bottom

      unless skip_default_scope
        default_scope { order(:position) }
      end
    end

    def parent_scope
      @_parent_scope
    end

    def parent_child_relation
      @_parent_child_relation
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
  end

  def regenerate_positions
    siblings =
      if parent_scope = self.class.parent_scope
        compute_parent_scope(parent_scope)
      else
        self.class.all
      end
    siblings.each_with_index do |obj, i|
      obj.update_column :position, i
    end
    reload
  end

  private

  def compute_parent_scope(parent_scope)
    send(parent_scope).send(self.class.parent_child_relation || self.class.to_s.underscore.pluralize)
  end
end
