module Madek
  module MediaResourceMigrationModels

    COLLECTION_LAYOUT_VALUES = %w(grid list miniature tiles)
    COLLECTION_SORTING_VALUES = %w(author created_at title updated_at)

    class ::MigrationMediaResource < ActiveRecord::Base
      self.table_name = 'media_resources'
      self.inheritance_column = nil
      store :settings

      has_and_belongs_to_many :migration_edit_sessions,
                              -> { reorder(:created_at, :id) },
                              join_table: 'edit_sessions',
                              foreign_key: 'resource_id',
                              association_foreign_key: 'user_id'
    end

    class ::MigrationMediaResourceArc < ActiveRecord::Base
      self.table_name = 'media_resource_arcs'
      belongs_to :child, class_name: 'MigrationMediaResource', foreign_key: :child_id
      belongs_to :parent, class_name: 'MigrationMediaResource', foreign_key: :parent_id
    end

    class ::MigrationMediaEntry < ActiveRecord::Base
      self.table_name = 'media_entries'
    end

    class ::MigrationCollection < ActiveRecord::Base
      enum layout: COLLECTION_LAYOUT_VALUES.map{|k| [k,k]}.to_h
      enum sorting:  COLLECTION_SORTING_VALUES.map{|k| [k,k]}.to_h

      self.table_name = 'collections'
    end

    class ::MigrationFilterSet < ActiveRecord::Base
      self.table_name = 'filter_sets'
    end

    class ::MigrationEditSession < ActiveRecord::Base
      self.table_name = 'edit_sessions'
    end

    class ::MigrationEntrySetArc < ActiveRecord::Base
      self.table_name = 'collection_media_entry_arcs'
    end

    class ::MigrationSetSetArc < ActiveRecord::Base
      self.table_name = 'collection_collection_arcs'
    end

    class ::MigrationFilterSetSetArc < ActiveRecord::Base
      self.table_name = 'collection_filter_set_arcs'
    end

    class ::MigrationUserPermission < ActiveRecord::Base
      self.table_name = :userpermissions
    end

    class ::MigrationUser < ActiveRecord::Base
      self.table_name = :users
    end

    class ::MigrationUsageTerms < ActiveRecord::Base
      self.table_name = :usage_terms
    end

    class ::MigrationMetaDatum < ActiveRecord::Base
      self.table_name = 'meta_data'
      belongs_to :media_resource, class_name: '::MigrationMediaResource', foreign_key: :media_resource_id
    end

    class ::MigrationMetaDatumLicense < ActiveRecord::Base
      self.table_name = 'meta_data'
      self.inheritance_column = nil
      belongs_to :license

      default_scope { where.not(license_id: nil) }
    end

    class ::MigrationMetaDataLicenses < ActiveRecord::Base
      self.table_name = 'meta_data_licenses'
    end

    class ::MigrationFavorite < ActiveRecord::Base
      self.table_name = 'favorites'
    end

    class ::MigrationFavoriteCollection < ActiveRecord::Base
      self.table_name = 'favorite_collections'
    end

    class ::MigrationFavoriteMediaEntry < ActiveRecord::Base
      self.table_name = 'favorite_media_entries'
    end

    class ::MigrationFavoriteFilterSet < ActiveRecord::Base
      self.table_name = 'favorite_filter_sets'
    end
  end
end
