class MediaEntry < ApplicationRecord
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
  # Ex. `MediaEntry
  #        .joins(:custom_urls)
  #        .where(custom_urls: { is_primary: true })
  #        .find('custom_id')
  ################################################################################

  VIEW_PERMISSION_NAME = :get_metadata_and_previews
  EDIT_PERMISSION_NAME = :edit_metadata
  MANAGE_PERMISSION_NAME = :edit_permissions

  include Collections::Siblings
  include MediaEntries::Filters
  include MediaEntries::Siblings
  include MediaResources
  include MediaResources::CustomOrderBy
  include MediaResources::Editability
  include MediaResources::Highlight
  include MediaResources::MetaDataArelConditions
  include MediaResources::PartOfWorkflow
  include MediaResources::SoftDelete
  include SharedOrderBy
  include SharedScopes
  include Delegations::Responsible

  has_one :media_file, dependent: :destroy

  has_many :collection_media_entry_arcs,
           class_name: 'Arcs::CollectionMediaEntryArc'
  has_many :parent_collections,
           through: :collection_media_entry_arcs,
           source: :collection

  has_many :confidential_links, as: :resource
  attr_accessor :accessed_by_confidential_link

  scope :ordered, -> { reorder(:created_at, :id) }
  scope :published, -> { where(is_published: true) }
  scope :not_published, -> { where(is_published: false) }
  scope :with_unpublished, -> { rewhere(is_published: [true, false]) }
  default_scope { not_deleted.published.ordered }

  # NOTE: could possibly be made as a DB trigger
  validate :validate_existence_of_meta_data_for_required_context_keys,
           if: :is_published?

  def self.joins_meta_data_title
    joins_meta_data_title_by_classname
  end

  def self.order_by_last_edit_session
    order_by_last_edit_session_by_classname
  end

  def self.order_by_manual_sorting
    order_by_manual_sorting_by_classname
  end

  def self.not_part_of_workflow
    joins('LEFT OUTER JOIN collections ON '\
          "collections.id IN (#{parent_collections_query})")
      .joins('LEFT OUTER JOIN workflows ON workflows.id = collections.workflow_id')
      .where('workflows.id IS NULL')
  end
end
