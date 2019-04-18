class ContextKeysCleanup < ActiveRecord::Migration[4.2]
  def change

    %w(meta_keys context_keys).each do |table|

      %w(label description hint).each do |column_name|

        cmd = <<-SQL.strip_heredoc
          UPDATE #{table}
            SET #{column_name} = NULL
            WHERE #{column_name} ~ '^\\s*$';
        SQL
        execute cmd
      end

    end

    %w(label description hint).each do |column_name|
      execute <<-SQL.strip_heredoc
        UPDATE context_keys
          SET #{column_name} = NULL
          FROM meta_keys
          WHERE meta_key_id = meta_keys.id
          AND meta_keys.#{column_name} = context_keys.#{column_name}
      SQL
    end

  end
end
