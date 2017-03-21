module Concerns
  module MediaResources
    module MetaData
      extend ActiveSupport::Concern
      include Concerns::ContextsHelpers

      included do
        has_many :meta_data
      end

      def title
        @_md_title ||= (
          meta_data.find_by(meta_key_id: 'madek_core:title').try(:to_s).presence \
            || title_fallback)
      end

      def subtitle
        @_md_subtitle ||= \
          meta_data.find_by(meta_key_id: 'madek_core:subtitle').try(:to_s)
      end

      def description
        @_md_description ||= \
          meta_data.find_by(meta_key_id: 'madek_core:description').try(:to_s)
      end

      def authors
        @_md_authors ||= \
          meta_data.find_by(meta_key_id: 'madek_core:authors').try(:to_s)
      end

      def copyright_notice
        @_md_copyright_notice ||= \
          meta_data.find_by(meta_key_id: 'madek_core:copyright_notice').try(:to_s)
      end

      def keywords
        @_md_keywords ||= \
          meta_data.find_by(meta_key_id: 'madek_core:keywords').try(:keywords)
      end

      private

      def title_fallback
        if self.is_a?(MediaEntry)
          self.try(:media_file).try(:filename) \
            || "(Upload from #{self.try(:created_at).try(:iso8601)})"
        else
          "<#{self.class} has no title>"
        end
      end

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
