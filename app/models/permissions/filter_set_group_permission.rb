module Permissions
  class FilterSetGroupPermission < ActiveRecord::Base
    include ::Permissions::Modules::FilterSet
    include ::Permissions::Modules::ArelConditions

    belongs_to :group

    #################### AREL #########################

    define_group_permission_for_user_exists_condition('filter_sets')
  end
end
