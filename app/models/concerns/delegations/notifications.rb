module Delegations
  module Notifications
    extend ActiveSupport::Concern

    included do
      def users_to_be_notified
        if notify_all_members?
          (
            users +
            groups.map(&:users).flatten +
            supervisors
          ).uniq
        else
          supervisors
        end
      end
    end
  end
end
