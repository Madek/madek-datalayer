module MetaKeys
  module MetaDatumObjectType
    module PeopleRoles
      extend ActiveSupport::Concern

      included do
        has_many :roles
        before_validation :sanitize_allowed_people_subtypes

        def can_have_people_subtypes?
          meta_datum_object_type == 'MetaDatum::People'
        end

        def can_have_roles?
          meta_datum_object_type == 'MetaDatum::Roles'
        end

        def allowed_people_subtypes
          if can_have_roles?
            %w(Person PeopleGroup)
          else
            self[:allowed_people_subtypes]
          end
        end

        private

        def sanitize_allowed_people_subtypes
          # do not run for previous migrations
          return unless respond_to?(:allowed_people_subtypes)
          return unless allowed_people_subtypes.is_a?(Array)
          self.allowed_people_subtypes = allowed_people_subtypes.reject(&:blank?)
        end
      end
    end
  end
end
