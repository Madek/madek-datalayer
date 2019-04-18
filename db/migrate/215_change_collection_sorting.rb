class ChangeCollectionSorting < ActiveRecord::Migration[4.2]
  COLLECTION_SORTING_VALUES = \
    ['created_at ASC', 'created_at DESC', 'title ASC', 'title DESC']

  def change
    execute <<-SQL.strip_heredoc
      CREATE TYPE collection_sorting_tmp AS ENUM ( #{COLLECTION_SORTING_VALUES.map{|x| "'#{x}'"}.join(', ')} );
    SQL

    add_column :collections, :sorting_tmp, :collection_sorting_tmp, null: false, default: 'created_at DESC'

    execute <<-SQL.strip_heredoc
      UPDATE collections
      SET sorting_tmp = 'created_at DESC'
      WHERE sorting = 'created_at'
    SQL

    execute <<-SQL.strip_heredoc
      UPDATE collections
      SET sorting_tmp = 'created_at DESC'
      WHERE sorting = 'updated_at'
    SQL

    execute <<-SQL.strip_heredoc
      UPDATE collections
      SET sorting_tmp = 'created_at DESC'
      WHERE sorting = 'author'
    SQL

    execute <<-SQL.strip_heredoc
      UPDATE collections
      SET sorting_tmp = 'title ASC'
      WHERE sorting = 'title'
    SQL

    remove_column :collections, :sorting
    rename_column :collections, :sorting_tmp, :sorting

    execute <<-SQL.strip_heredoc
      DROP TYPE collection_sorting;
      ALTER TYPE collection_sorting_tmp RENAME TO collection_sorting;
    SQL
  end
end
