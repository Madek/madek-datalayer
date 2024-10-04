module MediaResources
  module SoftDelete
    extend ActiveSupport::Concern

    included do
      scope :not_deleted, -> { where("#{table_name}.deleted_at IS NULL").or(where("#{table_name}.deleted_at > ?", Time.current)) }
      scope :deleted, -> { where.not("#{table_name}.deleted_at IS NULL").where("#{table_name}.deleted_at <= ?", Time.current) }

      def soft_delete
        update!(deleted_at: Time.current)
      end

      def deleted?
        deleted_at.present? and ( Time.current > deleted_at )
      end

      def self.delete_soft_deleted
        unscoped.where("#{table_name}.deleted_at < ?", 6.months.ago).find_each do |resource|
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
