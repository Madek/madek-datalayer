module Delegations
  module Responsible
    extend ActiveSupport::Concern

    included do
      belongs_to :responsible_delegation, class_name: 'Delegation'
      validate do |resource|
        cond = [:responsible_user, :responsible_delegation].one? do |attr|
          resource["#{attr}_id"].nil?
        end

        errors.add(:base, 'Only one responsible entity can be set at the same time') unless cond
      end
      scope :with_responsible_delegation,
            ->(delegation) { where(responsible_delegation: delegation) }
      scope :with_responsible_user_or_member_of_delegation,
            ->(user) { where(responsible_user: user).or(where(responsible_delegation: user.all_delegations)) }
    end

    def delegation_with_user?(user)
      return false if responsible_delegation.nil?

      ids = self.class.connection.exec_query(user.delegation_ids.to_sql).rows.flatten
      ids.include?(responsible_delegation_id)
    end
  end
end
