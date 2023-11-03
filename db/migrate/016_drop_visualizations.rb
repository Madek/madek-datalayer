class DropVisualizations < ActiveRecord::Migration[6.0]

  def up
    execute <<-SQL.strip_heredoc
      DROP TABLE IF EXISTS visualizations;
    SQL
  end

  def down
  end

end

