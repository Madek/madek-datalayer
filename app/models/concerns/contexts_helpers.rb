module Concerns
  module ContextsHelpers
    def context_ids_for_required_context_keys_validation
      AppSetting.first.contexts_for_entry_validation
    end
  end
end
