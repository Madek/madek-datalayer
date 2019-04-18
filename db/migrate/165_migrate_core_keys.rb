class MigrateCoreKeys < ActiveRecord::Migration[4.2]

  class MetaKey < ActiveRecord::Base ; end
  class IoMapping < ActiveRecord::Base ; end
  class MetaData < ActiveRecord::Base ; end
  class MetaKeyDefinitions < ActiveRecord::Base ; end
  class Keyword < ActiveRecord::Base ; end
  class Vocabulary < ActiveRecord::Base; end


  def change


    Vocabulary.find_or_create_by id: "madek_core", label: "Madek Core",
      description: "This is the predefined and immutable Madek core vocabulary."

    execute "SET session_replication_role = REPLICA;"

    # Die folgenden 2 Liste bestimmen
    # - welche MetaKeys im `madek_core` sind (`madek_core_vocabulary`)
    # - welche v2-MetaKeys dorthin migriert werden (`mapping`)
    # - beides inhaltlich übernommen vom alten Kontext "Core"
    # - Vorsicht: andere Instanzen haben dieses Mapping nicht, kann aber im Admin-UI gefixed werden (MetaKeys "umziehen" Feature)

    # TODO:
    # - core, mapping: description
    # - core: copright/license (not just 'notice')
    # - core: rename portrayed_object_date

    # configure for prod and personas (errors are ignored…)
    mapping = {
      # NEW : [ OLD, …]     # first personas, second PROD (if differs)
      'madek_core:title' => ['media_content:title'],
      'madek_core:subtitle' => ['media_content:subtitle'],
      'madek_core:description' => ['media_content:description'],
      'madek_core:keywords' => ['media_content:keywords'],
      'madek_core:authors' => ['media_content:author', 'media_object:author'],
      'madek_core:portrayed_object_date' => ['media_content:portrayed_object_dates', 'media_content:portrayed_object_date'],
      'madek_core:copyright_notice' => ['copyright:copyright_notice'],
    }

    madek_core_vocabulary = [

      { id: 'madek_core:title',
        label: 'Title',
        meta_datum_object_type: 'MetaDatum::Text',
        is_enabled_for_media_entries: true,
        is_enabled_for_collections: true,
        is_enabled_for_filter_sets: true,
        vocabulary_id: 'madek_core' },

      { id: 'madek_core:subtitle',
        label: 'Subtitle',
        meta_datum_object_type: 'MetaDatum::Text',
        is_enabled_for_media_entries: true,
        is_enabled_for_collections: true,
        is_enabled_for_filter_sets: true,
        vocabulary_id: 'madek_core' },

      { id: 'madek_core:description',
        label: 'Description',
        meta_datum_object_type: 'MetaDatum::Text',
        is_enabled_for_media_entries: true,
        is_enabled_for_collections: true,
        is_enabled_for_filter_sets: true,
        vocabulary_id: 'madek_core' },

      { id: 'madek_core:keywords',
        label: 'Schlagworte',
        meta_datum_object_type: 'MetaDatum::Keywords',
        is_enabled_for_media_entries: true,
        is_enabled_for_collections: true,
        is_enabled_for_filter_sets: true,
        vocabulary_id: 'madek_core' },

      { id: 'madek_core:authors',
        label: 'Autoren',
        meta_datum_object_type: 'MetaDatum::People',
        is_enabled_for_media_entries: true,
        is_enabled_for_collections: false,
        is_enabled_for_filter_sets: false,
        vocabulary_id: 'madek_core' },

      { id: 'madek_core:portrayed_object_date',
        label: 'Datierung',
        meta_datum_object_type: 'MetaDatum::TextDate',
        is_enabled_for_media_entries: true,
        is_enabled_for_collections: false,
        is_enabled_for_filter_sets: false,
        vocabulary_id: 'madek_core' },

      { id: 'madek_core:copyright_notice',
        label: 'Rechteinhaber',
        meta_datum_object_type: 'MetaDatum::Text',
        is_enabled_for_media_entries: true,
        is_enabled_for_collections: false,
        is_enabled_for_filter_sets: false,
        vocabulary_id: 'madek_core' },


    ].each do |new_mk|

      # create core MK:
      meta_key = MetaKey.create(new_mk)

      # migrate mapped MK(s):
      if (mapped_meta_keys = mapping[new_mk[:id]])

        mapped_meta_keys.each do |old_mk_id|
          # NOTE: don't fail if mapped MK is not found!
          if (old_mk = MetaKey.find_by(id: old_mk_id))

            # needed sanity check in case disparate types are mapped:
            unless old_mk.meta_datum_object_type == new_mk[:meta_datum_object_type]
              throw "Type mismatch! #{old_mk.attributes} → #{new_mk.attributes}"
            end

            # remove old MK
            old_mk.destroy!

            # re-link relations to mapped MK(s):
            [MetaKeyDefinitions,MetaData,Keyword,IoMapping].each do |klass|
              klass.where(meta_key_id: old_mk_id).find_each do |model|
                model.update_columns(meta_key_id: new_mk[:id])
              end
            end
          end
        end
      end

    end

    execute "SET session_replication_role = DEFAULT;"

  end

end
