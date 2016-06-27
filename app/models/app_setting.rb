class AppSetting < ActiveRecord::Base
  validate :featured_set_existence, if: proc { |record|
    record.featured_set_id.present?
  }

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
    context_for_show_summary
    contexts_for_show_extra
    contexts_for_list_details
    contexts_for_validation
    contexts_for_dynamic_filters
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

  private

  def include_context?(attr, context_id)
    attributes[attr].respond_to?(:include?) && \
      attributes[attr].include?(context_id) || \
      attributes[attr] == context_id
  end

  def featured_set_existence
    unless Collection.find_by_id(featured_set_id)
      errors.add(
        :base,
        "The set with a given ID: #{featured_set_id} doesn't exist!"
      )
    end
  end
end
