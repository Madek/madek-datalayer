# copied from current version of `Rails.root.join('db', 'seeds_and_defaults.yml')`,
# but not used directly because it'll change over time.
DB_SEEDS_DEF = <<~YAML
  MADEK_CORE_VOCABULARY:
    id: madek_core
    labels:
      de: 'Madek Core'
      en: 'Madek Core'
    descriptions:
      de: >
        Das Core-Vokabular ist fester Bestandteil der Software Madek.
        Es enthält die wichtigsten Metadaten für die Beschreibung von Medieninhalten
        und ist vordefiniert und unveränderbar.
      en: >
        The Core vocabulary is an integral part of the software Madek.
        It contains the most important metadata for describing media content
        and is predefined and immutable.
    meta_keys:
      madek_core:title:
        meta_datum_object_type: MetaDatum::Text
        text_type: line
        labels:
          en: Title
          de: Titel
        descriptions:
          en: NULL
          de: NULL
        hints:
          en: NULL
          de: NULL
        position: 1
        is_enabled_for_media_entries: true
        is_enabled_for_collections: true
        is_enabled_for_filter_sets: true
        vocabulary_id: madek_core
        admin_comment: NULL

      madek_core:subtitle:
        meta_datum_object_type: MetaDatum::Text
        text_type: line
        labels:
          en: Subtitle
          de: Untertitel
        descriptions:
          en: NULL
          de: NULL
        hints:
          en: NULL
          de: NULL
        position: 2
        is_enabled_for_media_entries: true
        is_enabled_for_collections: true
        is_enabled_for_filter_sets: true
        vocabulary_id: madek_core
        admin_comment: NULL

      madek_core:authors:
        meta_datum_object_type: MetaDatum::People
        labels:
          en: Author
          de: Autor/in
        descriptions:
          en: NULL
          de: NULL
        hints:
          en: NULL
          de: NULL
        position: 3
        is_enabled_for_media_entries: true
        is_enabled_for_collections: true
        is_enabled_for_filter_sets: false
        vocabulary_id: madek_core
        admin_comment: NULL

      madek_core:portrayed_object_date:
        meta_datum_object_type: MetaDatum::TextDate
        labels:
          en: Date
          de: Datierung
        descriptions:
          en: NULL
          de: NULL
        hints:
          en: NULL
          de: NULL
        position: 4
        is_enabled_for_media_entries: true
        is_enabled_for_collections: true
        is_enabled_for_filter_sets: false
        vocabulary_id: madek_core
        admin_comment: NULL

      madek_core:keywords:
        is_extensible_list: true
        meta_datum_object_type: MetaDatum::Keywords
        keywords_alphabetical_order: true
        labels:
          en: Keywords
          de: Schlagworte
        descriptions:
          en: NULL
          de: NULL
        hints:
          en: NULL
          de: NULL
        position: 5
        is_enabled_for_media_entries: true
        is_enabled_for_collections: true
        is_enabled_for_filter_sets: true
        vocabulary_id: madek_core
        admin_comment: NULL

      madek_core:description:
        meta_datum_object_type: MetaDatum::Text
        text_type: block
        labels:
          en: Description
          de: Beschreibung
        descriptions:
          en: NULL
          de: NULL
        hints:
          en: NULL
          de: NULL
        position: 6
        is_enabled_for_media_entries: true
        is_enabled_for_collections: true
        is_enabled_for_filter_sets: true
        vocabulary_id: madek_core
        admin_comment: NULL

      madek_core:copyright_notice:
        meta_datum_object_type: MetaDatum::Text
        text_type: line
        labels:
          en: Copyright Notice
          de: Urheberrechtshinweis
        descriptions:
          en: NULL
          de: NULL
        hints:
          en: NULL
          de: NULL
        position: 7
        is_enabled_for_media_entries: true
        is_enabled_for_collections: true
        is_enabled_for_filter_sets: false
        vocabulary_id: madek_core
        admin_comment: NULL
YAML

class ApplyCoreVocabTextChanges < ActiveRecord::Migration[4.2]
  class MigrationVocabulary < ActiveRecord::Base
    self.table_name = :vocabularies
  end
  DB_SEEDS = YAML.safe_load(DB_SEEDS_DEF).deep_symbolize_keys
  CORE_VOCAB = DB_SEEDS[:MADEK_CORE_VOCABULARY]

  def change
    # re-apply label and description from the otherwise unchangeable core vocab,
    # to import the english translations into newly transalatable fields
    # (2019-04-24)
    execute 'SET session_replication_role = REPLICA;'
    MigrationVocabulary.find(CORE_VOCAB[:id]).update_attributes!(
      CORE_VOCAB.slice(:labels, :descriptions)
        .map { |k, v| [k, v.try(:map) { |k, v| [k, v.try(:strip)] }.to_h] }.to_h)
    ActiveRecord::Base.connection.execute 'SET session_replication_role = DEFAULT;'
  end
end
