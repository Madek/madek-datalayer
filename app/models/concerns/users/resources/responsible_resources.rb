module Concerns
  module Users
    module Resources
      module ResponsibleResources
        extend ActiveSupport::Concern

        included do
          has_many :responsible_collections,
                   foreign_key: :responsible_user_id,
                   class_name: 'Collection'
          has_many :responsible_media_entries,
                   foreign_key: :responsible_user_id,
                   class_name: 'MediaEntry'
          has_many :responsible_filter_sets,
                   foreign_key: :responsible_user_id,
                   class_name: 'FilterSet'
        end
      end
    end
  end
end
