module Concerns
  module Users
    module Responsible
      extend ActiveSupport::Concern

      included do
        belongs_to :responsible_user, class_name: 'User'
        scope :in_responsibility_of, ->(user) { where(responsible_user: user) }
        singleton_class.send(:alias_method,
                             :with_responsible_user,
                             :in_responsibility_of)
      end
    end
  end
end
