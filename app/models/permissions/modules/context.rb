module Permissions
  module Modules
    module Context
      extend ActiveSupport::Concern
      include ::Permissions::Modules::DefineDestroyIneffective
      included do
        belongs_to :context
        define_destroy_ineffective [{ view: false, use: false }]
      end
      PERMISSION_TYPES = [:view, :use]
    end
  end
end
