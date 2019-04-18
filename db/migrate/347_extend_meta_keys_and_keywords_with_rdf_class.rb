class ExtendMetaKeysAndKeywordsWithRdfClass < ActiveRecord::Migration[4.2]

  # adds meta-information to keywords, especially an RDF class
  # adds relations between meta_keys and rdf_class
  #   - similar to 'meta_key.allowed_people_subtypes', but singular

  class ::RdfClass < ActiveRecord::Base
    self.table_name = :rdf_classes
    belongs_to :keyword # fkey not null
  end

  def up
    # ensure the rdf class that is used as a default exists
    RdfClass.find_or_create_by!(id: 'Keyword')

    execute <<-SQL

      ALTER TABLE keywords
        ADD COLUMN rdf_class character varying NOT NULL DEFAULT 'Keyword',
        ADD COLUMN description text,
        ADD COLUMN external_uri character varying,

        ADD FOREIGN KEY (rdf_class)
          REFERENCES rdf_classes(id)
          ON UPDATE CASCADE;

      ALTER TABLE meta_keys
        ADD COLUMN allowed_rdf_class character varying,
        ADD FOREIGN KEY (allowed_rdf_class)
          REFERENCES rdf_classes(id)
          ON UPDATE CASCADE;

    SQL
  end
end
