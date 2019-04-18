class Collection < ApplicationRecord
  ################################################################################
  # NOTE: The standard `find` and `find_by_id` methods are extended/overridden in
  # app/models/concerns/media_resources/custom_urls in order to accomodate
  # custom_ids. One can thus search for a particular resource using either its
  # uuid or custom_id.
  # There are two possible use cases:
  # 1. raise if resource is not found => use `find`
  # 2. return nil if resource is not found => use `find_by_id`
  #
  # `find_by(...)` or `find_by!(...)` are DISABLED. If you want to further
  # narrow down the scope when searching with a custom_id then do it this way:
  # Ex. `Collection
  #        .joins(:custom_urls)
  #        .where(custom_urls: { is_primary: true })
  #        .find('custom_id')
  ################################################################################

  VIEW_PERMISSION_NAME = :get_metadata_and_previews
  EDIT_PERMISSION_NAME = :edit_metadata_and_relations
  MANAGE_PERMISSION_NAME = :edit_permissions

  include Concerns::Collections::Arcs
  include Concerns::Collections::Siblings
  include Concerns::MediaResources
  include Concerns::MediaResources::CustomOrderBy
  include Concerns::MediaResources::Editability
  include Concerns::MediaResources::Highlight
  include Concerns::MediaResources::MetaDataArelConditions
  include Concerns::SharedOrderBy
  include Concerns::SharedScopes

  #################################################################################

  has_many :media_entries, through: :collection_media_entry_arcs

  has_many :highlighted_media_entries,
           through: :collection_media_entry_highlighted_arcs,
           source: :media_entry

  #################################################################################

  has_many :collections,
           through: :collection_collection_arcs_as_parent,
           source: :child

  has_many :highlighted_collections,
           through: :collection_collection_highlighted_arcs,
           source: :child

  has_many :parent_collections,
           through: :collection_collection_arcs_as_child,
           source: :parent

  #################################################################################

  has_many :filter_sets, through: :collection_filter_set_arcs

  has_many :highlighted_filter_sets,
           through: :collection_filter_set_highlighted_arcs,
           source: :filter_set

  #################################################################################

  scope :by_title, lambda{ |title|
    joins(:meta_data)
      .where(meta_data: { meta_key_id: 'madek_core:title' })
      .where('string ILIKE :title', title: "%#{title}%")
      .order(:created_at, :id)
  }

  default_scope { where(clipboard_user_id: nil).reorder(:created_at, :id) }

  # NOTE: could possibly be made as a DB trigger
  # NOTE: disabled because there is no workflow yet
  # validate :validate_existence_of_meta_data_for_required_context_keys

  def child_media_resources
    MediaResource.unified_scope(media_entries,
                                collections,
                                filter_sets)
  end

  def highlighted_media_resources
    MediaResource.unified_scope(highlighted_media_entries,
                                highlighted_collections,
                                highlighted_filter_sets)
  end

  def cover
    media_entries.find_by('collection_media_entry_arcs.cover = ?', true)
  end

  def cover=(media_entry)
    ActiveRecord::Base.transaction do
      Arcs::CollectionMediaEntryArc
        .find_by(collection: self, cover: true)
        .try(:update_attributes!, cover: false)
      Arcs::CollectionMediaEntryArc
        .find_by(collection: self, media_entry: media_entry)
        .update_attributes!(cover: true)
    end
  end

  def descendent_media_entries
    MediaEntry.joins(:collection_media_entry_arcs)
      .where("collection_media_entry_arcs.collection_id = '#{self.id}' OR "\
             'collection_media_entry_arcs.collection_id IN ' \
               "(#{Collection.descendent_collection_tree_sql_for(self.id)})")
  end

  def self.descendent_collection_tree_sql_for(collection_id)
    raise 'Not an UUID!' unless UUIDTools::UUID_REGEXP =~ collection_id

    <<-SQL
      WITH RECURSIVE collection_tree(parent_id, child_id, path) AS
        (SELECT parent_id, child_id, ARRAY[parent_id]
         FROM collection_collection_arcs
         WHERE parent_id = '#{collection_id}'
         UNION ALL SELECT cca.parent_id,
                          cca.child_id,
                          path || cca.parent_id
         FROM collection_tree
         INNER JOIN collection_collection_arcs cca
         ON cca.parent_id = collection_tree.child_id
         WHERE NOT cca.parent_id = ANY(path))
      SELECT collection_tree.child_id AS id FROM collection_tree
    SQL
  end

  def self.joins_meta_data_title
    joins_meta_data_title_by_classname
  end

  def self.order_by_last_edit_session
    order_by_last_edit_session_by_classname
  end
end
