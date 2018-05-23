class AppSetting < ActiveRecord::Base
  def self.validate_set_existence(name)
    validate :"#{name}_existence", if: proc { |record|
      record.send("#{name}_id").present?
    }

    define_method :"#{name}_existence" do
      unless Collection.find_by_id(send("#{name}_id"))
        errors.add(
          :base,
          "The set with a given ID: #{send("#{name}_id")} doesn't exist!"
        )
      end
    end

    private :"#{name}_existence"
  end

  [:default_locale, :available_locales].each do |method_name|
    define_singleton_method method_name do
      begin
        fallback = Settings.send("madek_#{method_name}")
        first.try(method_name) || fallback
      rescue ActiveRecord::StatementInvalid
        fallback
      end
    end
  end

  validate_set_existence(:featured_set)

  validate :catalog_context_keys_types

  def uses_context_as(context_id = nil)
    used_as = []
    attrs = attributes.select do |attr|
      attr.start_with?('context_for', 'contexts_for')
    end.keys

    attrs.each do |attr|
      next unless include_context?(attr, context_id)
      used_as << attr
    end

    used_as
  end

  %i(
    context_for_entry_summary
    context_for_collection_summary
    contexts_for_entry_extra
    contexts_for_collection_extra
    contexts_for_list_details
    contexts_for_entry_validation
    contexts_for_dynamic_filters
    contexts_for_entry_edit
    contexts_for_collection_edit
  ).each do |context_field|
    define_method context_field do
      ids = self[context_field]
      if context_field.to_s.start_with?('contexts_')
        Context.where(id: ids).sort_by { |c| ids.index(c.id) }
      else
        Context.find_by(id: ids)
      end
    end
  end

  def ignored_keyword_keys_for_browsing
    if (ids = self[:ignored_keyword_keys_for_browsing]).present?
      ids = ids.split(',').map(&:strip)
      MetaKey
        .with_type('MetaDatum::Keywords')
        .where(id: ids)
        .sort_by { |mk| ids.index(mk.id) }
    else
      []
    end
  end

  private

  def include_context?(attr, context_id)
    attributes[attr].respond_to?(:include?) && \
      attributes[attr].include?(context_id) || \
      attributes[attr] == context_id
  end

  def catalog_context_keys_types
    # FIXME: we need this check because of the migrations
    # might be removed when the migrations are changed
    if self.class.method_defined? :catalog_context_keys
      catalog_context_keys.each do |ck_id|
        context_key = ContextKey.find_by_id(ck_id)
        meta_key_type = context_key.try(:meta_key).try(:meta_datum_object_type)
        next if not meta_key_type or allowed_key_type?(meta_key_type)
        errors.add \
          :base,
          "The meta_key for context_key #{ck_id} " \
          "is not of type 'MetaDatum::Keywords'"
      end
    end
  end

  def allowed_key_type?(type)
    %w(
      MetaDatum::Keywords
      MetaDatum::People
    ).include?(type)
  end
end
