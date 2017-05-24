module Concerns
  module SharedScopes
    extend ActiveSupport::Concern

    included do
      scope :filter_by_visibility_public, lambda {
        where(get_metadata_and_previews: true)
      }

      scope :filter_by_visibility_shared, lambda {
        where(get_metadata_and_previews: false).where(
          sql_for_any_permissions
        )
      }

      scope :filter_by_visibility_private, lambda {
        where(get_metadata_and_previews: false).where.not(
          sql_for_any_permissions
        )
      }

      private

      # rubocop:disable Metrics/MethodLength
      def self.sql_for_any_permissions
        singular = name.underscore
        plural = singular.pluralize
        <<-SQL
          exists (
            select
              *
            from
              #{singular}_group_permissions
            where
              #{singular}_group_permissions.#{singular}_id = #{plural}.id
          )
          or
          exists (
            select
              *
            from
              #{singular}_user_permissions
            where
              #{singular}_user_permissions.#{singular}_id = #{plural}.id
          )
          or
          exists (
            select
              *
            from
              #{singular}_api_client_permissions
            where
              #{singular}_api_client_permissions.#{singular}_id = #{plural}.id
          )
        SQL
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
