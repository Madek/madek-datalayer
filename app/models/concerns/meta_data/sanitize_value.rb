module MetaData
  module SanitizeValue

    def reset_with_sanitized_value!(resources, type, acting_user = nil)
      with_sanitized(resources, acting_user) do |resources|
        reset_resources!(resources, type, acting_user)
      end
    end

    # `val` can be one of:
    # - string (text / uuid) or hash (for new entity)
    # - an array of strings (uuids) or hashes (for new entities).
    # In the case of uuids or hashes, the corresponding models have to be initialized.
    def with_sanitized(val, acting_user = nil)
      vals = (val.is_a?(Array) ? val : [val])
      sanitized_value = \
        extract_from_array_if_necessary \
          reject_blanks_and_modelify_if_necessary(vals, acting_user)
      raise 'Use safe value via block!' unless block_given?
      yield(sanitized_value)
    end

    private

    def reset_resources!(resources, type, acting_user)
      type_plural = type.pluralize
      assoc = self.send("meta_data_#{type_plural}")
      resources_to_remove = self.send(type_plural) - resources
      resources_to_add = resources - self.send(type_plural)

      # NOTE: Must do this inside a transaction, otherwise the MetaDatum (`self`)
      # will get cascade-deleted if all current resources are removed…
      ActiveRecord::Base.transaction do
        assoc.where(Hash[type, resources_to_remove]).delete_all
        resources_to_add.each do |resource|
          assoc << assoc.name.constantize.new(
            Hash[type, resource, :created_by, acting_user]
          )
        end
      end
      save!
    end

    def reject_blanks_and_modelify_if_necessary(vals, acting_user)
      vals
        .reject(&:blank?)
        .map { |v| modelify_if_necessary(v, acting_user) }
    end

    def modelify_if_necessary(val, acting_user)
      if self.value.class < ActiveRecord::Associations::CollectionProxy
        model = self.value.klass.find_or_build_resource!(val, self)
        if model.respond_to?(:creator_id)
          model.creator_id = acting_user.id
        end
        model
      else
        val
      end
    end

    def extract_from_array_if_necessary(val)
      need_to_extract_from_array? ? val.first : val
    end

    def need_to_extract_from_array?
      not self.value.class < ActiveRecord::Associations::CollectionProxy
    end
  end
end
