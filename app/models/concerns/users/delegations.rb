module Concerns
  module Users
    module Delegations
      extend ActiveSupport::Concern

      included do
        has_and_belongs_to_many :delegations
      end

      def all_delegations
        delegations_table = Delegation.arel_table
        delegation_ids = delegations.select(:id).map(&:id)
        ids_through_groups = Delegation.joins(groups: :users).where('users.id = ?', id).select(:id).map(&:id)
        Delegation.where(delegations_table[:id].in(delegation_ids.union(ids_through_groups)))
      end
    end
  end
end
