# copied from current version of `Rails.root.join('db', 'seeds_and_defaults.yml')`,
# but not used directly because it'll change over time.
MK_DEF = <<~YAML
  madek_core:is_new_version_of:
    meta_datum_object_type: MetaDatum::MediaEntry
    labels:
      en: is new version of
      de: ist neue Version von
    descriptions:
      en: This MediaEntry is a new Version of an older one. Enter additional text to specify the type of update.
      de: Dieser Medieneintrag ist eine neue Version eines älteren Eintrags. Geben Sie zusätzlichen Text ein, um die Art der Aktualisierung anzugeben.
    hints:
      en: Enter UUID of another MediaEntry.
      de: Geben Sie die UUID eines anderen MediaEntry ein.
    position: 8
    is_enabled_for_media_entries: true
    is_enabled_for_collections: false
    is_enabled_for_filter_sets: false
    vocabulary_id: madek_core
    admin_comment: |
      Equivalent to "IsVersionOf", a Controlled List Value for the DataCite-Property "relationType",
      see: <https://schema.datacite.org/meta/kernel-4.2/doc/DataCite-MetadataKernel_v4.2.pdf>
YAML

class AddCoreMetaKeyIsNewVersionOf < ActiveRecord::Migration[4.2]
  class MigrationVocabulary < ActiveRecord::Base
    self.table_name = :vocabularies
  end
  class MigrationMetaKey < ActiveRecord::Base
    self.table_name = :meta_keys
  end

  MigrationMetaKey.reset_column_information

  def change
    mk = YAML.safe_load(MK_DEF)
    id, attrs = mk.first
    execute 'SET session_replication_role = REPLICA;'
    MigrationMetaKey.create({id: id}.merge(attrs))
    execute 'SET session_replication_role = DEFAULT;'
  end
end
