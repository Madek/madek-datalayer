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
      end

      module ClassMethods
        def viewable_by_public
          where(Hash[self::VIEW_PERMISSION_NAME, true])
        end

        def viewable_by_user(user)
          conditions = arel_table[self::VIEW_PERMISSION_NAME].eq(true)
            .or(arel_table[:responsible_user_id].eq(user.id))
            .or("Permissions::#{name}UserPermission".constantize \
                  .user_permission_exists_condition \
                    self::VIEW_PERMISSION_NAME, user)
            .or("Permissions::#{name}GroupPermission".constantize \
                  .group_permission_for_user_exists_condition \
                    self::VIEW_PERMISSION_NAME, user)

          if self == MediaEntry
            scope_to_reuse = current_scope ? current_scope : self
            where(conditions)
              .or(
                scope_to_reuse
                  .with_unpublished
                  .where(viewable_by_workflow_creator(user)
                    .or(viewable_by_workflow_owner(user)))
              )
          else
            where(conditions)
          end
        end

        def viewable_by_user_or_public(user = nil)
          user ? viewable_by_user(user) : viewable_by_public
        end

        def viewable_by_workflow_creator(user)
          collection_media_entry_arcs =
            Arel::Table.new(:collection_media_entry_arcs)
          collections = Arel::Table.new(:collections)
          workflows = Arel::Table.new(:workflows)

          arel_table
            .project(1)
            .join(collection_media_entry_arcs)
            .on(collection_media_entry_arcs[:media_entry_id].eq(arel_table[:id]))
            .join(collections)
            .on(collections[:id].eq(collection_media_entry_arcs[:collection_id]))
            .join(workflows).on(workflows[:id].eq(collections[:workflow_id]))
            .where(workflows[:is_active].eq(true)
              .and(workflows[:creator_id].eq(user[:id])))
            .exists
        end

        def viewable_by_workflow_owner(user)
          collection_media_entry_arcs =
            Arel::Table.new(:collection_media_entry_arcs)
          collections = Arel::Table.new(:collections)
          workflows = Arel::Table.new(:workflows)
          users_workflows = Arel::Table.new(:users_workflows)

          arel_table
            .project(1)
            .join(collection_media_entry_arcs)
            .on(collection_media_entry_arcs[:media_entry_id].eq(arel_table[:id]))
            .join(collections)
            .on(collections[:id].eq(collection_media_entry_arcs[:collection_id]))
            .join(workflows).on(workflows[:id].eq(collections[:workflow_id]))
            .join(users_workflows).on(users_workflows[:user_id].eq(user[:id]))
            .where(workflows[:is_active].eq(true))
            .exists
        end
      end
    end
  end
end
