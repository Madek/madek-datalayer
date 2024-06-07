module Concerns
  module MediaResources
    module SoftDelete
      extend ActiveSupport::Concern

      included do
        scope :not_deleted, -> { where(deleted_at: nil) }
        scope :deleted, -> { where.not(deleted_at: nil) }

        def soft_delete
          update!(deleted_at: Time.current)
        end
      end
    end
  end
end
