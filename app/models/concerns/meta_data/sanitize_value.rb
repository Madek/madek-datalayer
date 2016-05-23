module Concerns
  module MetaData
    module SanitizeValue

      def reset_with_sanitized_value!(resources, type, created_by_user)
        with_sanitized(resources) do |resources|
          reset_resources!(resources, type, created_by_user)
        end
      end

      # val can be a string (text or uuid) or an array of strings (uuids).
      # In the case of uuids, the corresponding models have to be initialized.
      def with_sanitized(val)
        vals = (val.is_a?(Array) ? val : [val])
        sanitized_value = \
          extract_from_array_if_necessary \
            reject_blanks_and_modelify_if_necessary(vals)
        raise 'Use safe value via block!' unless block_given?
        yield(sanitized_value)
        # TODO: return safe_new_value
      end

      private

      def reset_resources!(resources, type, created_by_user)
        type_plural = type.pluralize
        assoc = self.send("meta_data_#{type_plural}")
        resources_to_remove = self.send(type_plural) - resources
        resources_to_add = resources - self.send(type_plural)

        # NOTE: Must do this inside a transaction, otherwise the MetaDatum (`self`)
        # will get cascade-deleted if all current resources are removed…
        ActiveRecord::Base.transaction do
          assoc.where(Hash[type, resources_to_remove]).delete_all
          resources_to_add.each do |resource|

            assoc << assoc.name.constantize.new(Hash[type, resource,
                                                     :created_by, created_by_user])
          end
        end
        save!
      end

      def reject_blanks_and_modelify_if_necessary(vals)
        vals
          .reject(&:blank?)
          .map { |v| modelify_if_necessary(v) }
      end

      def modelify_if_necessary(val)
        if self.value.class < ActiveRecord::Associations::CollectionProxy
          self.value.klass.find_or_build_resource!(val, self)
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
end
