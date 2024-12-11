class AlterCollectionSorting < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL
      ALTER TYPE public.collection_sorting ADD VALUE IF NOT EXISTS 'last_change DESC';
      ALTER TYPE public.collection_sorting ADD VALUE IF NOT EXISTS 'last_change ASC';
    SQL
  end

  def down
    execute <<~SQL
      UPDATE collections
      SET sorting = 'last_change DESC'
      WHERE sorting = 'last_change';
    SQL

    execute <<~SQL
      CREATE TYPE public.collection_sorting_new AS ENUM (
        'created_at ASC',
        'created_at DESC',
        'title ASC',
        'title DESC',
        'manual ASC',
        'manual DESC',
        'last_change DESC',
        'last_change ASC'
      );
    SQL

    execute <<~SQL
      ALTER TABLE collections ALTER COLUMN sorting TYPE public.collection_sorting_new USING sorting::text::public.collection_sorting_new;
    SQL

    execute <<~SQL
      DROP TYPE public.collection_sorting;
    SQL

    execute <<~SQL
      ALTER TYPE public.collection_sorting_new RENAME TO collection_sorting;
    SQL
  end
end
