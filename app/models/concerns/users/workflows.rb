module Users
  module Workflows
    extend ActiveSupport::Concern

    included do
      has_and_belongs_to_many :workflows
    end

    def delegated_workflows
      Workflow
        .joins('INNER JOIN delegations_workflows ON delegations_workflows.workflow_id = workflows.id')
        .joins('INNER JOIN delegations_users ON delegations_users.delegation_id = delegations_workflows.delegation_id')
        .where(delegations_users: { user_id: self.id })
        .distinct
    end

    def delegated_workflows_via_groups
      Workflow
        .joins('INNER JOIN delegations_workflows ON delegations_workflows.workflow_id = workflows.id')
        .joins('INNER JOIN delegations_groups ON delegations_groups.delegation_id = delegations_workflows.delegation_id')
        .joins('INNER JOIN groups_users ON groups_users.group_id = delegations_groups.group_id')
        .where(groups_users: { user_id: self.id })
        .distinct
    end

    def with_delegated_workflows
      ids =
        workflows.map(&:id)
        .union(delegated_workflows.map(&:id))
        .union(delegated_workflows_via_groups.map(&:id))

      Workflow.where(id: ids)
    end
  end
end
