class MediaResource < ApplicationRecord
  self.table_name = :vw_media_resources
  self.primary_key = :id
  # prevents Rails to treat the table/view as STI table
  self.inheritance_column = :_not_existing_column

  include MediaResources::CustomOrderBy

  def self.viewable_by_user_or_public(user, join_from_active_workflow: false)
    scopes = [MediaEntry, Collection].map do |mr_klass|
      mr_klass
        .viewable_by_user_or_public(user, join_from_active_workflow: join_from_active_workflow)
        .reorder(nil)
    end

    scope_to_use.unified_scope(scopes)
  end

  def self.filter_by(user = nil, opts)
    part_of_workflow = opts.delete(:part_of_workflow)

    if opts.blank?
      scope_to_use
    else
      scopes = [
        MediaEntry
        .try { |s| part_of_workflow ? s.with_unpublished : s }
        .filter_by(user, **opts)
        .reorder(nil),
        Collection.filter_by(user, **opts).reorder(nil)
      ]

      scope_to_use.unified_scope(scopes)
    end
  end

  def self.unified_scope(scopes, collection_id = nil)
    memoize_collection_id(collection_id)
    where_in(scopes)
  end

  def self.scope_to_use
    current_scope or all
  end

  def self.where_in(scopes)
    clause =
      scopes
      .map { |s| "vw_media_resources.id IN (#{s.select(:id).to_sql})" }
      .join(' OR ')

    where(clause)
  end

  def self.memoize_collection_id(id)
    return unless valid_uuid?(id)
    @_collection_id = id
  end

  private_class_method :memoize_collection_id

  def self.joins_meta_data_title
    joins(<<-SQL.strip_heredoc)
      INNER JOIN meta_data
      ON meta_data.meta_key_id = 'madek_core:title'
      AND (
        meta_data.media_entry_id = vw_media_resources.id
        OR meta_data.collection_id = vw_media_resources.id)
    SQL
  end

  # rubocop:disable Metrics/MethodLength
  def self.order_by_last_edit_session
    select(
      <<-SQL
        vw_media_resources.*,
        coalesce(
          media_entries.edit_session_updated_at,
          collections.edit_session_updated_at
        ) AS last_change
      SQL
    )
    .joins(
      <<-SQL
        LEFT JOIN media_entries
        ON (media_entries.id = vw_media_resources.id AND vw_media_resources.type = 'MediaEntry')
      SQL
    )
    .joins(
      <<-SQL
        LEFT JOIN collections
        ON (collections.id = vw_media_resources.id AND vw_media_resources.type = 'Collection')
      SQL
    )
  end
  # rubocop:enable Metrics/MethodLength

  def self.with_collection_id_condition(table_alias:, fk_field_name:)
    condition = if @_collection_id
                  Arel.sql(" AND #{table_alias}.#{fk_field_name} = '#{@_collection_id}'")
                else
                  ''
                end
    query = yield condition
    #@_collection_id = nil
    query
  end

  private_class_method :with_collection_id_condition

  # rubocop:disable Metrics/MethodLength
  def self.order_by_manual_sorting
    select(
      <<-SQL
        vw_media_resources.*,
        coalesce(cmea.position, cca.position) AS arc_position
      SQL
    )
    .joins(
      with_collection_id_condition(table_alias: 'cmea', fk_field_name: 'collection_id') do |condition|
        <<-SQL
          LEFT JOIN collection_media_entry_arcs cmea
          ON (
            cmea.media_entry_id = vw_media_resources.id AND
            vw_media_resources.type = 'MediaEntry'
            #{condition}
          )
        SQL
      end
    )
    .joins(
      with_collection_id_condition(table_alias: 'cca', fk_field_name: 'parent_id') do |condition|
          <<-SQL
          LEFT JOIN collection_collection_arcs cca
          ON (
            cca.child_id = vw_media_resources.id AND 
            vw_media_resources.type = 'Collection'
            #{condition}
          )
        SQL
      end
    )
  end
  # rubocop:enable Metrics/MethodLength

  def cast_to_type
    @_casted_to_type ||= becomes(type.constantize)
  end
end
