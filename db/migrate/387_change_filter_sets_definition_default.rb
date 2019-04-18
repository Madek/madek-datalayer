class ChangeFilterSetsDefinitionDefault < ActiveRecord::Migration[5.2]
  def up
    change_column_default :filter_sets, :definition, from: '{}', to: {}
    execute <<-SQL.strip_heredoc
      UPDATE filter_sets SET definition = '{}'::jsonb WHERE definition = '"{}"'
    SQL
  end
end
