module Users
  module Responsible
    extend ActiveSupport::Concern

    included do
      belongs_to :responsible_user, class_name: 'User'
      scope :in_responsibility_of, ->(user) { where(responsible_user: user) }
      singleton_class.send(:alias_method,
                            :with_responsible_user,
                            :in_responsibility_of)

      def responsible_entity_name
        if responsible_user
          responsible_user.to_s
        elsif responsible_delegation
          responsible_delegation.try(&:name).try(:concat, ' (Delegation)')
        else
          raise('No responsible entity!')
        end
      end
    end
  end
end
