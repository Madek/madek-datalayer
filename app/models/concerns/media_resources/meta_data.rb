module Concerns
  module MediaResources
    module MetaData
      extend ActiveSupport::Concern
      include Concerns::ContextsHelpers

      included do
        has_many :meta_data
      end

      def title
        meta_data.find_by(meta_key_id: 'madek_core:title').try(:value)
      end

      def description
        meta_data.find_by(meta_key_id: 'madek_core:description').try(:value)
      end

      def keywords
        Keyword
          .joins(:meta_data)
          .where(meta_data: Hash[
        :meta_key_id, 'madek_core:keywords',
        "#{self.class.model_name.singular}_id".to_sym, id])
      end

      private

      def validate_existence_of_meta_data_for_required_context_keys
        context_ids = context_ids_for_required_context_keys_validation
        ContextKey
          .where(context_id: context_ids, is_required: true)
          .each do |ck|
          next if meta_data.find_by_meta_key_id(ck.meta_key_id)
          errors.add \
            :base,
            "#{I18n.t(:meta_data_blank_value_for_required_meta_key_pre)}" \
            "#{ck.meta_key_id}" \
            "#{I18n.t(:meta_data_blank_value_for_required_meta_key_post)}"
        end
      end
    end
  end
end
