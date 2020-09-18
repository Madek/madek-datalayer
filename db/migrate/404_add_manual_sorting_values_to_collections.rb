class AddManualSortingValuesToCollections < ActiveRecord::Migration[5.2]
  COLLECTION_SORTING_VALUES = [
    'created_at ASC',
    'created_at DESC',
    'title ASC',
    'title DESC',
    'last_change',
    'manual ASC',
    'manual DESC'
  ].freeze

  def change
    execute <<-SQL.strip_heredoc
      ALTER TYPE collection_sorting RENAME TO tmp_collection_sorting
    SQL

    execute <<-SQL.strip_heredoc
      CREATE TYPE collection_sorting AS ENUM ( #{COLLECTION_SORTING_VALUES.map{|x| "'#{x}'"}.join(', ')} )
    SQL

    execute <<-SQL.strip_heredoc
      ALTER TABLE collections RENAME COLUMN sorting TO tmp_sorting
    SQL

    add_column :collections, :sorting, :collection_sorting, null: false, default: 'created_at DESC'

    execute <<-SQL.strip_heredoc
      UPDATE collections
      SET sorting = tmp_sorting::text::collection_sorting
    SQL

    remove_column :collections, :tmp_sorting

    execute <<-SQL.strip_heredoc
      drop type tmp_collection_sorting
    SQL
  end
end
