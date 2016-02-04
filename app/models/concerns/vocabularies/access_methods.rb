module Concerns
  module Vocabularies
    module AccessMethods
      extend ActiveSupport::Concern
      include Concerns::AccessHelpers

      module ClassMethods
        def define_vocabulary_access_methods(prefix, perm_type)
          define_access_methods prefix, perm_type do |user|
          user_permission_exists_condition(perm_type, user)
            .or(group_permission_for_user_exists_condition(perm_type, user))
            .or(arel_table["enabled_for_public_#{perm_type}"].eq true)
          end
        end
      end
    end
  end
end
