class MediaResource < ActiveRecord::Base
  self.table_name = :vw_media_resources
  self.primary_key = :id

  def self.viewable_by_user_or_public(user)
    scope_helper(:viewable_by_user_or_public, user)
  end

  def self.filter_by(user = nil, filter_opts)
    scope_helper(:filter_by, user, filter_opts)
  end

  def self.unified_scope(scope1, scope2, scope3)
    where(
      "id IN (#{scope1.select(:id).to_sql}) " \
      "OR id IN (#{scope2.select(:id).to_sql}) " \
      "OR id IN (#{scope3.select(:id).to_sql})"
    )
  end

  def self.scope_helper(method_name, *args)
    view_scope = \
      unified_scope(MediaEntry.send(method_name, *args).reorder(nil),
                    Collection.send(method_name, *args).reorder(nil),
                    FilterSet.send(method_name, *args).reorder(nil))

    sql = "((#{(current_scope or all).to_sql}) INTERSECT " \
           "(#{view_scope.to_sql})) AS vw_media_resources"
    from(sql)
  end

  private_class_method :scope_helper
end
