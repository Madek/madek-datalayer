class AddMetaKeysConstraints < ActiveRecord::Migration[4.2]
  def change

    %w(meta_keys context_keys).each do |table|

      %w(label description hint).each do |column_name|
        cmd = <<-SQL.strip_heredoc
          ALTER TABLE #{table}
            ADD CONSTRAINT check_#{column_name}_not_blank
            CHECK (#{column_name} !~ '^\\s*$');

          ALTER TABLE #{table}
            ALTER COLUMN #{column_name} SET DEFAULT NULL;
        SQL
        execute cmd
      end
    end
  end
end
