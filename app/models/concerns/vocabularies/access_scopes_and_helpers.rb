module Vocabularies
  module AccessScopesAndHelpers
    extend ActiveSupport::Concern
    include Vocabularies::AccessMethods

    def viewable_by_public?
      enabled_for_public_view?
    end

    def usable_by_public?
      enabled_for_public_use?
    end

    included do
      define_vocabulary_access_methods(:usable_by, :use)
      define_vocabulary_access_methods(:viewable_by, :view)
    end

    module ClassMethods
      def viewable_by_user_or_public(user = nil)
        user ? viewable_by_user(user) : where(enabled_for_public_view: true)
      end

      def usable_by_user_or_public(user = nil)
        user ? usable_by(user) : where(enabled_for_public_use: true)
      end
    end
  end
end
