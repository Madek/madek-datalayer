class AuditedChange < ApplicationRecord
  class << self
    def instance_method_already_implemented?(method_name)
      return true if ['changed', 'changed?'].include?(method_name)
      super
    end
  end
end
