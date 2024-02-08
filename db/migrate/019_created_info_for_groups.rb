class CreatedInfoForGroups < ActiveRecord::Migration[6.1]

  def change
    add_column(:groups, :created_at, :timestamptz)
    add_column(:groups, :updated_at, :timestamptz)

    reversible do |dir|
      dir.up do
        execute <<~SQL
          CREATE TRIGGER update_updated_at_column_of_groups
          BEFORE UPDATE ON groups
          FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*))
          EXECUTE FUNCTION update_updated_at_column();
        SQL
      end

      dir.down do
        execute <<~SQL
          DROP TRIGGER IF EXISTS update_updated_at_column_of_groups ON groups;
        SQL
      end
    end

    change_column(:groups, :created_at, :timestamptz, default: -> { "now()" })
    change_column(:groups, :updated_at, :timestamptz, default: -> { "now()" })

    add_column(:groups, :created_by_user_id, :uuid)
    add_foreign_key(:groups, :users, column: :created_by_user_id)
  end

end
