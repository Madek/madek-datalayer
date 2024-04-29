module Concerns
  module AccessHelpers
    extend ActiveSupport::Concern
    include Concerns::QueryHelpers

    module ClassMethods
      def define_access_methods(prefix, perm_type, &conditions)
        define_method "#{prefix}_user?" do |user|
          self.class
            .send("#{prefix}_user", user)
            .exists?(id: id)
        end

        define_singleton_method "#{prefix}_group" do |group|
          where \
            "Permissions::#{name}GroupPermission".constantize \
              .group_permission_exists_condition(perm_type, group)
        end

        if conditions
          define_singleton_method "#{prefix}_user" do |user, add_group_cond: nil|
            where yield(user, add_group_cond: add_group_cond)
          end
        end
      end
    end
  end
end
