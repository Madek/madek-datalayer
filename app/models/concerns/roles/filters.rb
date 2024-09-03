module Roles
  module Filters
    extend ActiveSupport::Concern

    class_methods do
      def filter_by(term = nil, meta_key_id = nil)
        roles = all

        if meta_key_id
          roles = Role.where('roles.meta_key_id = ?', meta_key_id)
        end

        return roles if term.nil?

        if valid_uuid?(term)
          roles = roles.where(id: term)
        else
          roles = roles
                    .where("array_to_string(avals(roles.labels), '||') ILIKE ?",
                            "%#{term}%")
        end

        roles
      end

      def of_vocabulary(vocabulary_id)
        if vocabulary_id.present?
          joins(:meta_key).where(meta_keys: { vocabulary_id: vocabulary_id })
        else
          all
        end
      end
    end
  end
end
