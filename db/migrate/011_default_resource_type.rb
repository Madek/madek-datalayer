class DefaultResourceType < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL
      CREATE TYPE public.collection_default_resource_type AS ENUM (
          'collections',
          'entries',
          'all'
      );
      ALTER TABLE collections ADD COLUMN default_resource_type collection_default_resource_type NOT NULL DEFAULT 'all';
    SQL
  end

  def down
    execute <<~SQL
      ALTER TABLE collections DROP COLUMN default_resource_type;
      DROP TYPE public.collection_default_resource_type;
    SQL
  end
end
