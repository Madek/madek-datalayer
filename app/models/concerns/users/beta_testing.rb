module Concerns
  module Users
    module BetaTesting
      extend ActiveSupport::Concern

      def beta_tester_notifications?
        groups
          .map(&:id)
          .include?(Madek::Constants::BETA_TESTERS_NOTIFICATIONS_GROUP_ID.to_s)
      end
    end
  end
end
