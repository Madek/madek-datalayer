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
            "Permissions::#{self.name}GroupPermission".constantize \
              .group_permission_exists_condition(perm_type, group)
        end

        if conditions
          define_singleton_method "#{prefix}_user" do |user|
            where yield(user)
          end
        end
      end
    end
  end
end
