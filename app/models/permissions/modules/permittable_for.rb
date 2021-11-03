module Permissions
  module Modules
    module PermittableFor
      extend ActiveSupport::Concern

      class_methods do
        def permitted_for?(perm_type, resource:, user:)
          resource_fk = resource.model_name.to_s.foreign_key

          where(
            arel_table
              .project(1)
              .where(
                arel_table[perm_type].eq(true)
                  .and(arel_table[resource_fk].eq(resource.id))
                  .and(
                    arel_table[:user_id].eq(user.id).or(
                      arel_table[:delegation_id].in(user.delegation_ids)
                    )
                  )
              ).exists
          ).exists?
        end
      end
    end
  end
end
