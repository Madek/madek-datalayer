class MigrateLicensesToKeywords < ActiveRecord::Migration[4.2]

  # - add rdf_class 'License'
  # - choose old "License"-meta_key and change to type keyword
  # - copy licenses to keywords with rdf_class='License' and chosen meta_key
  # - fix up the related metadata etc

  class MetaKey < ActiveRecord::Base
    self.table_name = :meta_keys
  end

  class License < ActiveRecord::Base
    self.table_name = :licenses
  end

  class Keyword < ActiveRecord::Base
    self.table_name = :keywords
    belongs_to :meta_key
  end

  class RdfClass < ActiveRecord::Base
    self.table_name = :rdf_classes
  end

  def up
    # because Keywords have to belong to a single MetaKey, we need to select one
    # and migrate it as well.
    # in practice, there should only exist 0 or 1 such Metakeys,
    # any other setup is not supported.
    mkeys = MetaKey.where(meta_datum_object_type: 'MetaDatum::Licenses')
    return if mkeys.count.zero?
    fail 'Only one MetaKey of type License is supported!' if mkeys.count > 1
    license_meta_key = mkeys.first

    # prepare RdfClass
    RdfClass.find_or_create_by!(id: 'License')

    # copy Licenses -> Keywords
    License.all.map do |l|
      Keyword.create!(
        id: l.id,
        term: l.label,
        description: l.usage,
        external_uri: l.url,
        meta_key: license_meta_key,
        rdf_class: 'License'
      )
    end

    ActiveRecord::Base.transaction do
      execute <<-SQL
        SET session_replication_role = REPLICA;

        -- copy meta_data licenses -> keywords
        INSERT INTO meta_data_keywords (meta_datum_id, keyword_id, created_by_id, meta_data_updated_at)
        	SELECT meta_datum_id, license_id as keyword_id, created_by_id, meta_data_updated_at
          FROM meta_data_licenses;

        -- migrate the MetaKey type
        UPDATE meta_keys
          SET meta_datum_object_type = 'MetaDatum::Keywords'
          WHERE id = '#{license_meta_key.id}';

        -- migrate MetaData types
        UPDATE meta_data
          SET type = 'MetaDatum::Keywords'
          WHERE type = 'MetaDatum::Licenses';

        SET session_replication_role = DEFAULT;
      SQL

    end
  end
end
