module Concerns
  module SharedScopes
    extend ActiveSupport::Concern

    included do
      scope :filter_by_visibility_public, lambda {
        where(get_metadata_and_previews: true)
      }

      scope :filter_by_visibility_user_or_group, lambda {
        where(get_metadata_and_previews: false).where(
          sql_for_user_or_group_permission
        )
      }

      scope :filter_by_visibility_api, lambda {
        where(get_metadata_and_previews: false).where(
          sql_for_api_permission
        )
      }

      scope :filter_by_visibility_private, lambda {
        where(get_metadata_and_previews: false).where.not(
          sql_for_user_or_group_permission
        ).where.not(
          sql_for_api_permission
        )
      }

      private

      def self.sql_for_api_permission
        singular = name.underscore
        plural = singular.pluralize
        <<-SQL
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

      def self.sql_for_user_or_group_permission
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
        SQL
      end
    end
  end
end
