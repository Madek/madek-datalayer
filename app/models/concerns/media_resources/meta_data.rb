module MediaResources
  module MetaData
    extend ActiveSupport::Concern
    include ContextsHelpers

    included do
      has_many :meta_data
    end

    # Madek#914: collection-level preload so authors_pretty does not N+1 Person loads.
    # Ideal form is preload(meta_data: :people), but that fails here:
    # - STI MetaDatum base has no :people
    # - :people ORDER BY meta_data_people.* breaks Preloader's people IN (...) query
    # Workaround: preload meta_data + join/person; MetaDatum::People#to_s uses that.
    def self.preload_for_list!(records)
      records = Array(records).compact
      return records if records.empty?

      ActiveRecord::Associations::Preloader.new(
        records: records,
        associations: :meta_data
      ).call

      people_meta_data = records.flat_map do |record|
        record.meta_data.select { |md| md.is_a?(MetaDatum::People) }
      end
      if people_meta_data.any?
        ActiveRecord::Associations::Preloader.new(
          records: people_meta_data,
          associations: { meta_data_people: :person }
        ).call
      end

      records
    end

    def title
      @_md_title ||= (
        meta_datum_for_key('madek_core:title').try(:to_s).presence \
          || title_fallback)
    end

    def subtitle
      @_md_subtitle ||= \
        meta_datum_for_key('madek_core:subtitle').try(:to_s)
    end

    def description
      @_md_description ||= \
        meta_datum_for_key('madek_core:description').try(:to_s)
    end

    def authors
      @_md_authors ||= \
        meta_datum_for_key('madek_core:authors').try(:to_s)
    end

    def copyright_notice
      @_md_copyright_notice ||= \
        meta_datum_for_key('madek_core:copyright_notice').try(:to_s)
    end

    def keywords
      @_md_keywords ||= \
        meta_datum_for_key('madek_core:keywords').try(:keywords)
    end

    private

    # find_by always hits SQL; use the loaded target after preload_for_list!.
    def meta_datum_for_key(meta_key_id)
      if meta_data.loaded?
        meta_data.find { |md| md.meta_key_id == meta_key_id }
      else
        meta_data.find_by(meta_key_id: meta_key_id)
      end
    end

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
