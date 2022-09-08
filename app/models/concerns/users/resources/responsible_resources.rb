module Concerns
  module Users
    module Resources
      module ResponsibleResources
        extend ActiveSupport::Concern
        included do
          has_many :responsible_collections,
                   foreign_key: :responsible_user_id,
                   class_name: 'Collection'
          has_many :responsible_media_entries,
                   foreign_key: :responsible_user_id,
                   class_name: 'MediaEntry'

          define_delegated_association_for_resource(Collection)
          define_delegated_association_for_resource(MediaEntry)
        end

        class_methods do
          def define_delegated_association_for_resource(klass)
            define_method "delegated_#{klass.name.tableize}" do
              table = klass.arel_table

              klass.where(table[:responsible_delegation_id].in(delegation_ids))
            end
          end
        end

        def delegation_ids
          delegations_users = Arel::Table.new(:delegations_users)
          delegations_groups = Arel::Table.new(:delegations_groups)
          groups_users = Arel::Table.new(:groups_users)

          delegation_ids_from_groups = delegations_groups
            .project(:delegation_id)
            .where(
              delegations_groups[:group_id]
                .in(
                  groups_users.project(:group_id).where(groups_users[:user_id].eq(id))
                )
            )

          delegation_ids_from_users = delegations_users
            .project(:delegation_id)
            .where(delegations_users[:user_id].eq(id))

          delegation_ids_from_users.union(delegation_ids_from_groups)
        end
      end
    end
  end
end
