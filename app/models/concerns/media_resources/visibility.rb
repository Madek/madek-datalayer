module Concerns
  module MediaResources
    module Visibility
      extend ActiveSupport::Concern
      include Concerns::AccessHelpers

      def viewable_by_public?
        get_metadata_and_previews?
      end

      included do
        define_access_methods(:viewable_by, self::VIEW_PERMISSION_NAME)
        private_class_method :ids_viewable_by_workflow_member
        private_class_method :ids_viewable_by_workflow_creator
        private_class_method :ids_viewable_by_workflow_owner
        private_class_method :ids_viewable_by_workflow_delegated_owner
      end

      class_methods do
        def viewable_by_public
          where(Hash[self::VIEW_PERMISSION_NAME, true])
        end

        def viewable_by_user(user, join_from_active_workflow: false)
          conditions = arel_table[self::VIEW_PERMISSION_NAME].eq(true)
            .or(arel_table[:responsible_user_id].eq(user.id))
            .or(arel_table[:responsible_delegation_id].in(user.delegation_ids))
            .or("Permissions::#{name}UserPermission".constantize \
                  .user_permission_exists_condition \
                    self::VIEW_PERMISSION_NAME, user)
            .or("Permissions::#{name}GroupPermission".constantize \
                  .group_permission_for_user_exists_condition \
                    self::VIEW_PERMISSION_NAME, user)

          if join_from_active_workflow && self == MediaEntry
            scope_to_reuse = current_scope ? current_scope : self
            where(conditions)
              .or(
                scope_to_reuse
                  .rewhere(is_published: false)
                  .where(arel_table[:id].in(ids_viewable_by_workflow_member(user)))
              )
          else
            where(conditions)
          end
        end

        def viewable_by_user_or_public(user = nil, join_from_active_workflow: false)
          if user
            viewable_by_user(user, join_from_active_workflow: join_from_active_workflow)
          else
            viewable_by_public
          end
        end

        def ids_viewable_by_workflow_member(user)
          Arel::Nodes::Union.new(
            Arel::Nodes::Union.new(
              ids_viewable_by_workflow_creator(user),
              ids_viewable_by_workflow_owner(user)
            ),
            ids_viewable_by_workflow_delegated_owner(user)
          )
        end

        def ids_viewable_by_workflow_creator(user)
          collection_media_entry_arcs = Arel::Table.new(:collection_media_entry_arcs)
          collections = Arel::Table.new(:collections)
          workflows = Arel::Table.new(:workflows)

          arel_table
            .project(arel_table[:id])
            .join(collection_media_entry_arcs)
            .on(collection_media_entry_arcs[:media_entry_id].eq(arel_table[:id]))
            .join(collections)
            .on(collections[:id].eq(collection_media_entry_arcs[:collection_id]))
            .join(workflows).on(workflows[:id].eq(collections[:workflow_id]))
            .where(workflows[:is_active].eq(true)
              .and(workflows[:creator_id].eq(user[:id])))
        end

        def ids_viewable_by_workflow_owner(user)
          collection_media_entry_arcs = Arel::Table.new(:collection_media_entry_arcs)
          collections = Arel::Table.new(:collections)
          workflows = Arel::Table.new(:workflows)
          users_workflows = Arel::Table.new(:users_workflows)

          arel_table
            .project(arel_table[:id])
            .join(collection_media_entry_arcs)
            .on(collection_media_entry_arcs[:media_entry_id].eq(arel_table[:id]))
            .join(collections)
            .on(collections[:id].eq(collection_media_entry_arcs[:collection_id]))
            .join(workflows).on(workflows[:id].eq(collections[:workflow_id]))
            .join(users_workflows).on(
              users_workflows[:workflow_id].eq(workflows[:id])
                .and(users_workflows[:user_id].eq(user[:id]))
            )
            .where(workflows[:is_active].eq(true))
        end

        def ids_viewable_by_workflow_delegated_owner(user)
          collection_media_entry_arcs = Arel::Table.new(:collection_media_entry_arcs)
          collections = Arel::Table.new(:collections)
          workflows = Arel::Table.new(:workflows)
          delegations_workflows = Arel::Table.new(:delegations_workflows)

          arel_table
            .project(arel_table[:id])
            .join(collection_media_entry_arcs)
            .on(collection_media_entry_arcs[:media_entry_id].eq(arel_table[:id]))
            .join(collections)
            .on(collections[:id].eq(collection_media_entry_arcs[:collection_id]))
            .join(workflows).on(workflows[:id].eq(collections[:workflow_id]))
            .join(delegations_workflows)
            .on(delegations_workflows[:workflow_id].eq(workflows[:id]))
            .where(delegations_workflows[:delegation_id].in(user.delegation_ids))
            .where(workflows[:is_active].eq(true))
        end
      end
    end
  end
end
