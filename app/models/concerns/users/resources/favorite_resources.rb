module Concerns
  module Users
    module Resources
      module FavoriteResources
        extend ActiveSupport::Concern

        included do
          has_and_belongs_to_many :favorite_media_entries,
                                  join_table: 'favorite_media_entries',
                                  class_name: 'MediaEntry'
          has_and_belongs_to_many :favorite_collections,
                                  join_table: 'favorite_collections',
                                  class_name: 'Collection'
          has_and_belongs_to_many :favorite_filter_sets,
                                  join_table: 'favorite_filter_sets',
                                  class_name: 'FilterSet'
        end
      end
    end
  end
end
