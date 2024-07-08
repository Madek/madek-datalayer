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

        def self.delete_soft_deleted
          unscoped.where('deleted_at < ?', 6.month.ago).each do |resource|
            begin
              resource.meta_data.each(&:destroy!)
              resource.destroy!
            rescue => e
              Rails.logger.error "Error deleting soft deleted resource: #{resource.id} - #{e.message}"
            end
          end
        end
      end
    end
  end
end
