class AddRdfClasses < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL

      CREATE TABLE rdf_classes (
        id character varying NOT NULL,
        description text,
        admin_comment text,
        "position" integer DEFAULT 0 NOT NULL,
        UNIQUE (id),
        CONSTRAINT rdf_classes_pkey PRIMARY KEY (id),
        CONSTRAINT rdf_class_id_chars CHECK (((id)::text ~* '^[A-Za-z0-9]+$'::text)),
        CONSTRAINT rdf_class_id_start_uppercase CHECK (((id)::text ~ '^[A-Z]'::text))
      );

    SQL
  end
end
