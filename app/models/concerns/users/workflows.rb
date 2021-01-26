module Concerns
  module Users
    module Workflows
      extend ActiveSupport::Concern

      included do
        has_and_belongs_to_many :workflows
      end

      def with_delegated_workflows
        workflows_table = Workflow.arel_table
        delegations_workflows = Arel::Table.new(:delegations_workflows)
        delegated_workflow_ids = delegations_workflows
          .project(:workflow_id)
          .where(delegations_workflows[:delegation_id].in(delegation_ids))

        Workflow.where(workflows_table[:id].in(delegated_workflow_ids.union(workflows.select(:id))))
      end
    end
  end
end
