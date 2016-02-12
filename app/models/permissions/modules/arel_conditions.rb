module Permissions
  module Modules
    module ArelConditions
      extend ActiveSupport::Concern

      included do
        def self.build_where_conditions(resources_table,
                                        perm,
                                        arel_attribute,
                                        id)
          permissions = arel_table
          resources = Arel::Table.new(resources_table)

          permissions["#{resources_table.singularize}_id"].eq(resources[:id])
            .and(permissions[perm].eq(true))
            .and(arel_attribute.eq(id))
        end

        def self.define_group_permission_for_user_exists_condition(resources_table)
          define_singleton_method \
            :group_permission_for_user_exists_condition do |perm, user|

            permissions = arel_table
            groups = Group.arel_table
            groups_users = Arel::Table.new(:groups_users)

            permissions
              .join(groups).on(permissions[:group_id].eq(groups[:id]))
              .join(groups_users).on(groups_users[:group_id].eq(groups[:id]))
              .project(1)
              .where(build_where_conditions(resources_table,
                                            perm,
                                            groups_users[:user_id],
                                            user))
              .exists
          end
        end

        def self.define_user_permission_exists_condition(resources_table)
          define_singleton_method \
            :user_permission_exists_condition do |perm, user|

            permissions_exists_condition_helper(resources_table,
                                                perm,
                                                arel_table[:user_id],
                                                user)
          end
        end

        def self.define_group_permission_exists_condition(resources_table)
          define_singleton_method \
            :group_permission_exists_condition do |perm, group|

            permissions_exists_condition_helper(resources_table,
                                                perm,
                                                arel_table[:group_id],
                                                group)
          end
        end

        def self.permissions_exists_condition_helper(resources_table,
                                                     perm,
                                                     arel_attribute,
                                                     subject)
          permissions = arel_table
          permissions
            .project(1)
            .where(build_where_conditions(resources_table,
                                          perm,
                                          arel_attribute,
                                          subject.try(:id)))
            .exists
        end
      end
    end
  end
end
