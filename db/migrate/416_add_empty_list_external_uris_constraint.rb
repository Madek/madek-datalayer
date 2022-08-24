class AddEmptyListExternalUrisConstraint < ActiveRecord::Migration[5.2]
  def up
    [:people, :keywords].each do |table|
      execute <<~SQL
        UPDATE #{table} SET external_uris = '{}' WHERE external_uris IS NULL;
      SQL
      change_column table, :external_uris, :string, array: true, default: '{}', null: false
    end
  end
end
