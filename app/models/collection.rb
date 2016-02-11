class Collection < ActiveRecord::Base

  VIEW_PERMISSION_NAME = :get_metadata_and_previews
  EDIT_PERMISSION_NAME = :edit_metadata_and_relations

  include Concerns::Collections::Arcs
  include Concerns::Collections::Siblings
  include Concerns::MediaResources
  include Concerns::MediaResources::MetaDataArelConditions
  include Concerns::MediaResources::Editability
  include Concerns::MediaResources::Highlight

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

  default_scope { reorder(:created_at, :id) }

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
end
