class Collection < ApplicationRecord
  VIEW_PERMISSION_NAME = :get_metadata_and_previews
  EDIT_PERMISSION_NAME = :edit_metadata_and_relations
  MANAGE_PERMISSION_NAME = :edit_permissions

  include Collections::Arcs
  include Collections::Siblings
  include MediaResources
  include MediaResources::CustomOrderBy
  include MediaResources::Editability
  include MediaResources::Highlight
  include MediaResources::MetaDataArelConditions
  include MediaResources::SoftDelete
  include SharedOrderBy
  include SharedScopes
  include Delegations::Responsible

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

  scope :search_with, lambda{ |title|
    joins(:meta_data)
      .where(meta_data: { meta_key_id: 'madek_core:title' })
      .where('string ILIKE :title', title: "%#{title}%")
      .or(where('collections.id::text = :collection_id', collection_id: title))
      .order(:created_at, :id)
      .distinct
  }

  scope :not_in_clipboard, lambda { where(clipboard_user_id: nil) }
  scope :ordered, -> { reorder(:created_at, :id) }

  default_scope do
    not_deleted.not_in_clipboard.ordered
  end

  def child_media_resources(media_entries_scope: :media_entries)
    scopes = [
      public_send(media_entries_scope).reorder(nil),
      collections.reorder(nil)
    ]

    MediaResource.unified_scope(scopes, id)
  end

  def highlighted_media_resources
    MediaResource.unified_scope([highlighted_media_entries,
                                 highlighted_collections])
  end

  def cover
    media_entries.find_by('collection_media_entry_arcs.cover = ?', true)
  end

  def cover=(media_entry)
    ActiveRecord::Base.transaction do
      Arcs::CollectionMediaEntryArc
        .find_by(collection: self, cover: true)
        .try(:update!, cover: false)
      Arcs::CollectionMediaEntryArc
        .find_by(collection: self, media_entry: media_entry)
        .update!(cover: true)
    end
  end

  def descendent_media_entries
    MediaEntry.joins(:collection_media_entry_arcs)
      .where("collection_media_entry_arcs.collection_id = '#{self.id}' OR "\
             'collection_media_entry_arcs.collection_id IN ' \
               "(#{Collection.descendent_collection_tree_sql_for(self.id)})")
  end

  def self.descendent_collection_tree_sql_for(collection_id)
    raise 'Not an UUID!' unless valid_uuid?(collection_id)

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

  def self.order_by_manual_sorting
    order_by_manual_sorting_by_classname
  end
end
