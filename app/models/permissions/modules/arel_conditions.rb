module Permissions
  module Modules
    module ArelConditions
      extend ActiveSupport::Concern

      class_methods do
        def build_where_conditions(resources_table,
                                   perm,
                                   arel_attribute,
                                   id,
                                   or_condition: nil)
          permissions = arel_table
          resources = Arel::Table.new(resources_table)

          permissions["#{resources_table.singularize}_id"].eq(resources[:id])
            .and(permissions[perm].eq(true))
            .and(
              apply_or_condition(
                arel_attribute.eq(id),
                or_condition
              )
            )
        end

        def define_group_permission_for_user_exists_condition(resources_table)
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
                                            user.try(:id)))
              .exists
          end
        end

        def define_user_permission_exists_condition(resources_table)
          define_singleton_method \
            :user_permission_exists_condition do |perm, user|

            permissions_exists_condition_helper(resources_table,
                                                perm,
                                                [arel_table[:user_id], arel_table[:delegation_id]],
                                                user)
          end
        end

        def define_group_permission_exists_condition(resources_table)
          define_singleton_method \
            :group_permission_exists_condition do |perm, group|

            permissions_exists_condition_helper(resources_table,
                                                perm,
                                                arel_table[:group_id],
                                                group)
          end
        end

        def define_api_client_permission_exists_condition(resources_table)
          define_singleton_method \
            :api_client_permission_exists_condition do |perm, api_client|

            permissions_exists_condition_helper(resources_table,
                                                perm,
                                                arel_table[:api_client_id],
                                                api_client)
          end
        end

        def permissions_exists_condition_helper(resources_table,
                                                perm,
                                                arel_attribute,
                                                subject)
          permissions = arel_table
          arel_attributes = Array.wrap(arel_attribute)
          arel_attribute = arel_attributes.first
          or_condition = or_condition_for_delegation(resources_table,
                                                     arel_attributes,
                                                     subject)

          permissions
            .project(1)
            .where(build_where_conditions(resources_table,
                                          perm,
                                          arel_attribute,
                                          subject.try(:id),
                                          or_condition: or_condition))
            .exists
        end

        def or_condition_for_delegation(resources_table, arel_attributes, subject)
          if resources_table.presence_in(%w(media_entries collections)) &&
             (arel_attribute = arel_attributes.detect { |attr| attr.name.to_s == 'delegation_id' })

            arel_attribute.in(subject.delegation_ids)
          end
        end

        def apply_or_condition(condition, or_condition)
          return condition unless or_condition

          condition.or(or_condition)
        end
      end

      included do
        private_class_method :build_where_conditions,
                             :or_condition_for_delegation,
                             :apply_or_condition
      end
    end
  end
end
